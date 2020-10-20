//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoKeyManager
import SudoLogging
import AWSCognitoIdentityProvider
import AWSCore
import AWSAppSync
import SudoConfigManager
import SudoUser
import SudoApiClient

/// Default implementation for `SudoSecureVaultClient`.
public class DefaultSudoSecureVaultClient: SudoSecureVaultClient {

    /// Configuration parameter names.
    public struct Config {

        // Configuration namespace.
        struct Namespace {
            // Secure Vault service related configuration.
            static let secureVaultService = "secureVaultService"
        }

        struct SecureVaultService {
            // AWS region hosting the Secure Vault service.
            static let region = "region"
            // AWS Cognito user pool ID of the Secure Vault service.
            static let userPoolId = "poolId"
            // ID of the client configured to access the user pool.
            static let clientId = "clientId"
            // API URL.
            static let apiUrl = "apiUrl"
            // PBKDF rounds.
            static let pbkdfRounds = "pbkdfRounds"
        }

    }

    private struct Constants {

        struct Encryption {
            static let saltSize = 32
            static let algorithmAES256 = "AES/256"
        }

        struct KeyManager {
            static let defaultKeyManagerNamespace = "svs"
            static let defaultKeyManagerServiceName = "com.sudoplatform.appservicename"
            static let defaultKeyManagerKeyTag = "com.sudoplatform"
        }

    }

    /// Default logger for SudoSecureVaultClient.
    private let logger: Logger

    /// KeyManager instance used for cryptographic operations.
    private var keyManager: SudoKeyManager

    /// GraphQL client used calling Secure Vault service API.
    private let graphQLClient: AWSAppSyncClient

    public var version: String {
        return SUDO_SECURE_VAULT_VERSION
    }

    private let queue = DispatchQueue(label: "com.sudoplatform.securevault")

    private var registerOperationQueue = SecureVaultOperationQueue()

    private var apiOperationQueue = SecureVaultOperationQueue()

    private let sudoUserClient: SudoUserClient

    /// Identity provider to use for registration and authentication.
    private var identityProvider: IdentityProvider

    /// Config provider used to initialize an `AWSAppSyncClient` that can talk to GraphQL endpoint of
    /// the Secure Vault  service.
    private let configProvider: SudoSecureVaultClientConfigProvider

    /// Default PBKDF rounds.
    private let pbkdfRounds: UInt32

    /// Client initialization data.
    private var initializationData: InitializationData?

    /// Intializes a new `DefaultSudoSecureVaultClient` instance.
    ///
    /// - Parameters:
    ///   - sudoUserClient: `SudoUserClient` instance required to issue authentication tokens and perform cryptographic operations.
    ///   - logger: A logger to use for logging messages. If none provided then a default internal logger will be used.
    /// - Throws: `SudoSecureVaultClientError`
    convenience public init(sudoUserClient: SudoUserClient, logger: Logger? = nil) throws {
        var config: [String: Any] = [:]

        if let configManager = DefaultSudoConfigManager(),
            let secureVaultServiceConfig = configManager.getConfigSet(namespace: Config.Namespace.secureVaultService) {
            config[Config.Namespace.secureVaultService] = secureVaultServiceConfig
        }

        try self.init(config: config, sudoUserClient: sudoUserClient, logger: logger)
    }

    /// Intializes a new `DefaultSudoSecureVaultClient` instance.
    ///
    /// - Parameters:
    ///   - config: Configuration parameters for the client.
    ///   - sudoUserClient: `SudoUserClient` instance required to issue authentication tokens and perform cryptographic operations.
    ///   - keyManager: `SudoKeyManager` instance to use to perform cryptographic operations.
    ///   - identityProvider: Identity provider to use to user management. Mainly used for unit testing.
    ///         Mainly used for unit testing.
    ///   - graphQlClient: GrpahQL client to use for Secure Vault service API. Mainly used for unit testing.
    ///   - logger: A logger to use for logging messages. If none provided then a default
    ///         internal logger will be used.
    public init(config: [String: Any],
                sudoUserClient: SudoUserClient,
                keyManager: SudoKeyManager? = nil,
                identityProvider: IdentityProvider? = nil,
                graphQLClient: AWSAppSyncClient? = nil,
                logger: Logger? = nil) throws {
        let logger = logger ?? Logger.sudoSecureVaultLogger
        self.sudoUserClient = sudoUserClient
        self.logger = logger

        self.logger.debug("Initializing with config: \(config)")

        self.keyManager = keyManager ?? SudoKeyManagerImpl(serviceName: Constants.KeyManager.defaultKeyManagerServiceName,
                                                           keyTag: Constants.KeyManager.defaultKeyManagerKeyTag,
                                                           namespace: Constants.KeyManager.defaultKeyManagerNamespace)

        guard let secureVaultServiceConfig = config[Config.Namespace.secureVaultService] as? [String: Any] else {
            throw SudoSecureVaultClientError.invalidConfig
        }

        guard let pbkdfRounds = secureVaultServiceConfig[Config.SecureVaultService.pbkdfRounds] as? Int else {
            throw SudoSecureVaultClientError.invalidConfig
        }

        self.pbkdfRounds = UInt32(pbkdfRounds)

        try self.identityProvider = identityProvider ?? CognitoUserPoolIdentityProvider(config: secureVaultServiceConfig, logger: logger)

        guard let configProvider = SudoSecureVaultClientConfigProvider(config: secureVaultServiceConfig) else {
            throw SudoSecureVaultClientError.invalidConfig
        }

        self.configProvider = configProvider

        if let graphQLClient = graphQLClient {
            self.graphQLClient = graphQLClient
        } else {
            // Set up an `AWSAppSyncClient` to call GraphQL API that requires sign in.
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: configProvider,
                                                                  userPoolsAuthProvider: GraphQLAuthProvider(client: self.sudoUserClient),
                                                                  urlSessionConfiguration: URLSessionConfiguration.ephemeral,
                                                                  cacheConfiguration: AWSAppSyncCacheConfiguration.inMemory,
                                                                  connectionStateChangeHandler: nil,
                                                                  s3ObjectManager: nil,
                                                                  presignedURLClient: nil,
                                                                  retryStrategy: .aggressive)
            self.graphQLClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            self.graphQLClient.apolloClient?.cacheKeyForObject = { $0["id"] }
        }
    }

    private func generateSecretKeyData(
        key: Data,
        password: Data,
        salt: Data,
        rounds: UInt32
    ) throws -> Data {
        // Stretch the key by performing 1 round of PBKDF.
        let keyData = try self.keyManager.createSymmetricKeyFromPassword(key, salt: salt, rounds: 1)
        let passwordData = try self.keyManager.createSymmetricKeyFromPassword(password, salt: salt, rounds: rounds)
        return try passwordData.xor(rhs: keyData)
    }

    public func isRegistered(completion: @escaping (Swift.Result<Bool, Error>) -> Void) throws {
        if self.initializationData != nil {
            return completion(.success(true))
        } else {
            try self.getInitializationData { (result) in
                switch result {
                case let .success(initializationData):
                    completion(.success(initializationData != nil))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    public func register(key: Data, password: Data, completion: @escaping (Swift.Result<String, Error>) -> Void) throws {
        self.logger.info("Performing registration.")

        guard let sub = try self.sudoUserClient.getSubject(),
              let token = try self.sudoUserClient.getIdToken() else {
            throw SudoSecureVaultClientError.notSignedIn
        }

        try self.queue.sync {
            // TODO: Check if the user is already registered.

            guard self.registerOperationQueue.operationCount == 0 else {
                throw SudoSecureVaultClientError.registerOperationAlreadyInProgress
            }

            try self.reset()

            let authenticationSalt = try self.keyManager.createRandomData(Constants.Encryption.saltSize)
            let encryptionSalt = try self.keyManager.createRandomData(Constants.Encryption.saltSize)
            var secretData = try self.generateSecretKeyData(key: key, password: password, salt: authenticationSalt, rounds: self.pbkdfRounds)

            let op = Register(uid: sub,
                              password: secretData.base64EncodedString(),
                              token: token,
                              authenticationSalt: authenticationSalt.base64EncodedString(),
                              encryptionSalt: encryptionSalt.base64EncodedString(),
                              pbkdfRounds: self.pbkdfRounds,
                              identityProvider: self.identityProvider,
                              logger: self.logger)
            op.completionBlock = {
                secretData.fill(byte: 0)

                if let error = op.error {
                    completion(.failure(error))
                } else {
                    self.initializationData = InitializationData(owner: op.uid, authenticationSalt: authenticationSalt, encryptionSalt: encryptionSalt, pbkdfRounds: Int(self.pbkdfRounds))
                    completion(.success(op.uid))
                }
            }

            self.registerOperationQueue.addOperation(op)
        }
    }

    public func getInitializationData(completion: @escaping (Swift.Result<InitializationData?, Error>) -> Void) throws {
        self.logger.info("Retrieving client initialization data.")

        guard try self.sudoUserClient.isSignedIn() else {
            throw SudoSecureVaultClientError.notSignedIn
        }

        self.graphQLClient.fetch(query: GetInitializationDataQuery(), cachePolicy: .fetchIgnoringCacheData) { (result, error) in
            if let error = error {
                return completion(.failure(error))
            }

            guard let result = result else {
                return completion(.failure(SudoSecureVaultClientError.fatalError(description: "Query returned nil result.")))
            }

            if let errors = result.errors {
                let message = "Query failed with errors: \(errors)"
                self.logger.error(message)
                return completion(.failure(SudoSecureVaultClientError.graphQLError(description: message)))
            }

            guard let initializationData = result.data?.getInitializationData else {
                return completion(.success(nil))
            }

            guard let authenticationSalt = Data(base64Encoded: initializationData.authenticationSalt),
                  let encryptionSalt = Data(base64Encoded: initializationData.encryptionSalt) else {
                return completion(.failure(SudoSecureVaultClientError.fatalError(description: "Failed to decode salts in the initialization data.")))
            }

            let data = InitializationData(owner: initializationData.owner, authenticationSalt: authenticationSalt, encryptionSalt: encryptionSalt, pbkdfRounds: initializationData.pbkdfRounds)
            self.initializationData = data
            completion(.success(data))
        }
    }

    public func deregister(completion: @escaping (Swift.Result<String, Error>) -> Void) throws {
        self.logger.info("Performing deregistration.")

        guard try self.sudoUserClient.isSignedIn() else {
            throw SudoSecureVaultClientError.notSignedIn
        }

        let deregisterOp = Deregister(graphQLClient: self.graphQLClient, logger: self.logger)

        deregisterOp.completionBlock = {
            if let error = deregisterOp.error {
                completion(.failure(error))
            } else {
                guard let uid = deregisterOp.uid else {
                    return completion(.failure(SudoSecureVaultClientError.fatalError(description: "Deregister operation completed successfully but no user ID was returned.")))
                }

                self.initializationData = nil
                completion(.success(uid))
            }
        }

        self.apiOperationQueue.addOperation(deregisterOp)
    }

    public func createVault(key: Data, password: Data, blob: Data, blobFormat: String, ownershipProof: String, completion: @escaping (Swift.Result<VaultMetadata, Error>) -> Void) throws {
        self.logger.info("Creating a new vault.")

        guard try self.sudoUserClient.isSignedIn() else {
            throw SudoSecureVaultClientError.notSignedIn
        }

        guard let sub = try self.sudoUserClient.getSubject() else {
            throw SudoSecureVaultClientError.fatalError(description: "Cannot retrieve sub of signed in user.")
        }

        guard let initializationData = self.initializationData else {
            throw SudoSecureVaultClientError.notRegistered
        }

        var authenticationSecret = try self.generateSecretKeyData(key: key, password: password, salt: initializationData.authenticationSalt, rounds: UInt32(initializationData.pbkdfRounds))

        let signInOp = SignIn(uid: sub, password: authenticationSecret.base64EncodedString(), identityProvider: self.identityProvider, logger: self.logger)

        var encryptionSecret = try self.generateSecretKeyData(key: key, password: password, salt: initializationData.encryptionSalt, rounds: UInt32(initializationData.pbkdfRounds))

        let createVaultOp = CreateVault(key: encryptionSecret, blob: blob, blobFormat: blobFormat, ownershipProofs: [ownershipProof], keyManager: self.keyManager, graphQLClient: self.graphQLClient, logger: self.logger)
        createVaultOp.copyDependenciesOutputAsInput = true
        createVaultOp.addDependency(signInOp)

        let operations = [signInOp, createVaultOp]

        createVaultOp.completionBlock = {
            authenticationSecret.fill(byte: 0)
            encryptionSecret.fill(byte: 0)

            if let error = operations.compactMap({ $0.error }).first {
                completion(.failure(error))
            } else {
                guard let vaultMetadata = createVaultOp.vaultMetada else {
                    return completion(.failure(SudoSecureVaultClientError.fatalError(description: "Create vault operation completed successfully but no vault metadata was returned.")))
                }
                completion(.success(vaultMetadata))
            }
        }

        self.apiOperationQueue.addOperations(operations, waitUntilFinished: false)
    }

    public func updateVault(key: Data, password: Data, id: String, version: Int, blob: Data, blobFormat: String, completion: @escaping (Swift.Result<VaultMetadata, Error>) -> Void) throws {
        self.logger.info("Updating a vault.")

        guard try self.sudoUserClient.isSignedIn() else {
            throw SudoSecureVaultClientError.notSignedIn
        }

        guard let sub = try self.sudoUserClient.getSubject() else {
            throw SudoSecureVaultClientError.fatalError(description: "Cannot retrieve sub of signed in user.")
        }

        guard let initializationData = self.initializationData else {
            throw SudoSecureVaultClientError.notRegistered
        }

        var authenticationSecret = try self.generateSecretKeyData(key: key, password: password, salt: initializationData.authenticationSalt, rounds: UInt32(initializationData.pbkdfRounds))

        let signInOp = SignIn(uid: sub, password: authenticationSecret.base64EncodedString(), identityProvider: self.identityProvider, logger: self.logger)

        var encryptionSecret = try self.generateSecretKeyData(key: key, password: password, salt: initializationData.encryptionSalt, rounds: UInt32(initializationData.pbkdfRounds))

        let updateVaultOp = UpdateVault(key: encryptionSecret, id: id, expectedVersion: version, blob: blob, blobFormat: blobFormat, keyManager: self.keyManager, graphQLClient: self.graphQLClient, logger: self.logger)
        updateVaultOp.copyDependenciesOutputAsInput = true
        updateVaultOp.addDependency(signInOp)

        let operations = [signInOp, updateVaultOp]

        updateVaultOp.completionBlock = {
            authenticationSecret.fill(byte: 0)
            encryptionSecret.fill(byte: 0)

            if let error = operations.compactMap({ $0.error }).first {
                completion(.failure(error))
            } else {
                guard let vaultMetadata = updateVaultOp.vaultMetada else {
                    return completion(.failure(SudoSecureVaultClientError.fatalError(description: "Update vault operation completed successfully but no vault metadata was returned.")))
                }
                completion(.success(vaultMetadata))
            }
        }

        self.apiOperationQueue.addOperations(operations, waitUntilFinished: false)
    }

    public func deleteVault(id: String, completion: @escaping (Swift.Result<VaultMetadata?, Error>) -> Void) throws {
        self.logger.info("Deleting a vault.")

        guard try self.sudoUserClient.isSignedIn() else {
            throw SudoSecureVaultClientError.notSignedIn
        }

        let deleteVaultOp = DeleteVault(id: id, graphQLClient: self.graphQLClient, logger: self.logger)

        deleteVaultOp.completionBlock = {
            if let error = deleteVaultOp.error {
                completion(.failure(error))
            } else {
                guard let vaultMetadata = deleteVaultOp.vaultMetada else {
                    return completion(.failure(SudoSecureVaultClientError.fatalError(description: "Delete vault operation completed successfully but no vault metadata was returned.")))
                }
                completion(.success(vaultMetadata))
            }
        }

        self.apiOperationQueue.addOperation(deleteVaultOp)
    }

    public func getVault(key: Data, password: Data, id: String, completion: @escaping (Swift.Result<Vault?, Error>) -> Void) throws {
        self.logger.info("Retrieving a vault: id=\(id).")

        guard try self.sudoUserClient.isSignedIn() else {
            throw SudoSecureVaultClientError.notSignedIn
        }

        guard let sub = try self.sudoUserClient.getSubject() else {
            throw SudoSecureVaultClientError.fatalError(description: "Cannot retrieve sub of signed in user.")
        }

        guard let initializationData = self.initializationData else {
            throw SudoSecureVaultClientError.notRegistered
        }

        var authenticationSecret = try self.generateSecretKeyData(key: key, password: password, salt: initializationData.authenticationSalt, rounds: UInt32(initializationData.pbkdfRounds))

        let signInOp = SignIn(uid: sub, password: authenticationSecret.base64EncodedString(), identityProvider: self.identityProvider, logger: self.logger)

        var encryptionSecret = try self.generateSecretKeyData(key: key, password: password, salt: initializationData.encryptionSalt, rounds: UInt32(initializationData.pbkdfRounds))

        let getVaultOp = GetVault(key: encryptionSecret, id: id, keyManager: self.keyManager, graphQLClient: self.graphQLClient, logger: self.logger)
        getVaultOp.copyDependenciesOutputAsInput = true
        getVaultOp.addDependency(signInOp)

        let operations = [signInOp, getVaultOp]

        getVaultOp.completionBlock = {
            authenticationSecret.fill(byte: 0)
            encryptionSecret.fill(byte: 0)

            if let error = operations.compactMap({ $0.error }).first {
                completion(.failure(error))
            } else {
                guard let vault = getVaultOp.vault else {
                    return completion(.failure(SudoSecureVaultClientError.fatalError(description: "Update vault operation completed successfully but no vault metadata was returned.")))
                }
                completion(.success(vault))
            }
        }

        self.apiOperationQueue.addOperations(operations, waitUntilFinished: false)
    }

    public func listVaults(key: Data, password: Data, completion: @escaping (Swift.Result<[Vault], Error>) -> Void) throws {
        self.logger.info("Retrieving vaults.")

        guard try self.sudoUserClient.isSignedIn() else {
            throw SudoSecureVaultClientError.notSignedIn
        }

        guard let sub = try self.sudoUserClient.getSubject() else {
            throw SudoSecureVaultClientError.fatalError(description: "Cannot retrieve sub of signed in user.")
        }

        guard let initializationData = self.initializationData else {
            throw SudoSecureVaultClientError.notRegistered
        }

        var authenticationSecret = try self.generateSecretKeyData(key: key, password: password, salt: initializationData.authenticationSalt, rounds: UInt32(initializationData.pbkdfRounds))

        let signInOp = SignIn(uid: sub, password: authenticationSecret.base64EncodedString(), identityProvider: self.identityProvider, logger: self.logger)

        var encryptionSecret = try self.generateSecretKeyData(key: key, password: password, salt: initializationData.encryptionSalt, rounds: UInt32(initializationData.pbkdfRounds))

        let listVaultsOp = ListVaults(key: encryptionSecret, keyManager: self.keyManager, graphQLClient: self.graphQLClient, logger: self.logger)
        listVaultsOp.copyDependenciesOutputAsInput = true
        listVaultsOp.addDependency(signInOp)

        let operations = [signInOp, listVaultsOp]

        listVaultsOp.completionBlock = {
            authenticationSecret.fill(byte: 0)
            encryptionSecret.fill(byte: 0)

            if let error = operations.compactMap({ $0.error }).first {
                completion(.failure(error))
            } else {
                completion(.success(listVaultsOp.vaults))
            }
        }

        self.apiOperationQueue.addOperations(operations, waitUntilFinished: false)
    }

    public func listVaultsMetadataOnly(completion: @escaping (Swift.Result<[VaultMetadata], Error>) -> Void) throws {
        self.logger.info("Retrieving vaults (metadata only).")

        guard try self.sudoUserClient.isSignedIn() else {
            throw SudoSecureVaultClientError.notSignedIn
        }

        let listVaultsMetadataOnlyOp = ListVaultsMetadataOnly(graphQLClient: self.graphQLClient, logger: self.logger)

        listVaultsMetadataOnlyOp.completionBlock = {
            if let error = listVaultsMetadataOnlyOp.error {
                completion(.failure(error))
            } else {
                completion(.success(listVaultsMetadataOnlyOp.vaults))
            }
        }

        self.apiOperationQueue.addOperation(listVaultsMetadataOnlyOp)
    }

    public func changeVaultPassword(key: Data, oldPassword: Data, newPassword: Data, completion: @escaping (Swift.Result<Void, Error>) -> Void) throws {
        self.logger.info("Changing vault password.")

        guard let sub = try self.sudoUserClient.getSubject() else {
            throw SudoSecureVaultClientError.notSignedIn
        }

        guard let initializationData = self.initializationData else {
            throw SudoSecureVaultClientError.notRegistered
        }

        var oldAuthenticationSecret = try self.generateSecretKeyData(key: key, password: oldPassword, salt: initializationData.authenticationSalt, rounds: UInt32(initializationData.pbkdfRounds))

        var newAuthenticationSecret = try self.generateSecretKeyData(key: key, password: newPassword, salt: initializationData.authenticationSalt, rounds: UInt32(initializationData.pbkdfRounds))

        let signInOp = SignIn(uid: sub, password: oldAuthenticationSecret.base64EncodedString(), identityProvider: self.identityProvider, logger: self.logger)

        var oldEncryptionSecret = try self.generateSecretKeyData(key: key, password: oldPassword, salt: initializationData.encryptionSalt, rounds: UInt32(initializationData.pbkdfRounds))

        var newEncryptionSecret = try self.generateSecretKeyData(key: key, password: newPassword, salt: initializationData.encryptionSalt, rounds: UInt32(initializationData.pbkdfRounds))

        let listVaultsOp = ListVaults(key: oldEncryptionSecret, keyManager: self.keyManager, graphQLClient: self.graphQLClient, logger: self.logger)
        listVaultsOp.copyDependenciesOutputAsInput = true
        listVaultsOp.addDependency(signInOp)

        let changePasswordOp = ChangePassword(uid: sub, oldPassword: oldAuthenticationSecret.base64EncodedString(), newPassword: newAuthenticationSecret.base64EncodedString(), identityProvider: self.identityProvider, logger: self.logger)
        changePasswordOp.addDependency(listVaultsOp)

        let operations = [signInOp, listVaultsOp, changePasswordOp]

        changePasswordOp.completionBlock = {
            oldAuthenticationSecret.fill(byte: 0)
            oldEncryptionSecret.fill(byte: 0)

            if let error = operations.compactMap({ $0.error }).first {
                completion(.failure(error))
            } else {
                var updateVaultOps: [SecureVaultOperation] = []
                for vault in listVaultsOp.vaults {
                    let signInOp = SignIn(uid: sub, password: newAuthenticationSecret.base64EncodedString(), identityProvider: self.identityProvider, logger: self.logger)
                    if let lastOp = updateVaultOps.last {
                        signInOp.addDependency(lastOp)
                    }
                    updateVaultOps.append(signInOp)

                    let updateVaultOp = UpdateVault(key: newEncryptionSecret, id: vault.id, expectedVersion: vault.version, blob: vault.blob, blobFormat: vault.blobFormat, keyManager: self.keyManager, graphQLClient: self.graphQLClient, logger: self.logger)
                    updateVaultOp.addDependency(signInOp)
                    updateVaultOp.copyDependenciesOutputAsInput = true
                    updateVaultOps.append(updateVaultOp)
                }

                if let lastOp = updateVaultOps.last {
                    lastOp.completionBlock = {
                        newAuthenticationSecret.fill(byte: 0)
                        newEncryptionSecret.fill(byte: 0)

                        if let error = operations.compactMap({ $0.error }).first {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }

                    self.apiOperationQueue.addOperations(updateVaultOps, waitUntilFinished: false)
                } else {
                    newAuthenticationSecret.fill(byte: 0)
                    newEncryptionSecret.fill(byte: 0)
                    completion(.success(()))
                }
            }
        }

        self.apiOperationQueue.addOperations(operations, waitUntilFinished: false)
    }

    public func reset() throws {
        self.logger.info("Resetting client.")
        self.initializationData = nil
        try self.graphQLClient.clearCaches()
    }

}
