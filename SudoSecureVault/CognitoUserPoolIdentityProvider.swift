//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoLogging
import AWSCognitoIdentityProvider

/// Identity provider that uses Cognito user pool.
public class CognitoUserPoolIdentityProvider: IdentityProvider {

    /// Configuration parameter names.
    public struct Config {
        // AWS region hosting Secure Vault service.
        static let region = "region"
        // AWS Cognito user pool ID of Secure Vault service.
        static let poolId = "poolId"
        // ID of the client configured to access the user pool.
        static let clientId = "clientId"
    }

    private struct Constants {

        static let secureVaultServiceName = "com.sudoplatform.securevaultservice"

        struct ServiceError {
            static let message = "message"
            static let decodingError = "sudoplatform.DecodingError"
            static let serviceError = "sudoplatform.ServiceError"
        }

        struct ValidationData {
            static let idToken = "idToken"
            static let authenticationSalt = "authenticationSalt"
            static let encryptionSalt = "encryptionSalt"
            static let pbkdfRounds = "pbkdfRounds"
        }

    }

    private var userPool: AWSCognitoIdentityUserPool

    private var serviceConfig: AWSServiceConfiguration

    private unowned var logger: Logger

    /// Initializes and returns a `CognitoUserPoolIdentityProvider` object.
    ///
    /// - Parameters:
    ///   - config: Configuration parameters for this identity provider.
    ///   - logger: Logger used for logging.
    init(config: [String: Any],
         logger: Logger = Logger.sudoSecureVaultLogger) throws {
        self.logger = logger

        self.logger.debug("Initializing with config: \(config)")

        // Validate the config.
        guard let region = config[Config.region] as? String,
              let poolId = config[Config.poolId] as? String,
              let clientId = config[Config.clientId] as? String else {
            throw IdentityProviderError.invalidConfig
        }

        guard let regionType = AWSEndpoint.regionTypeFrom(name: region) else {
            throw IdentityProviderError.invalidConfig
        }

        // Initialize the user pool instance.
        guard let serviceConfig = AWSServiceConfiguration(region: regionType, credentialsProvider: nil) else {
            throw IdentityProviderError.fatalError(description: "Failed to initialize AWS service configuration.")
        }

        self.serviceConfig = serviceConfig

        AWSCognitoIdentityProvider.register(with: self.serviceConfig, forKey: Constants.secureVaultServiceName)

        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: clientId, clientSecret: nil, poolId: poolId)
        AWSCognitoIdentityUserPool.register(with: serviceConfig, userPoolConfiguration: poolConfiguration, forKey: Constants.secureVaultServiceName)
        guard let userPool = AWSCognitoIdentityUserPool(forKey: Constants.secureVaultServiceName) else {
            throw IdentityProviderError.fatalError(description: "Failed to locate user pool instance with service name: \(Constants.secureVaultServiceName)")
        }

        self.userPool = userPool
    }

    public func register(uid: String, password: String,
                         token: String,
                         authenticationSalt: String,
                         encryptionSalt: String,
                         pbkdfRounds: UInt32,
                         completion: @escaping (RegisterResult) -> Void) throws {

        let validationData = [
            AWSCognitoIdentityUserAttributeType(name: Constants.ValidationData.idToken, value: token),
            AWSCognitoIdentityUserAttributeType(name: Constants.ValidationData.authenticationSalt, value: authenticationSalt),
            AWSCognitoIdentityUserAttributeType(name: Constants.ValidationData.encryptionSalt, value: encryptionSalt),
            AWSCognitoIdentityUserAttributeType(name: Constants.ValidationData.pbkdfRounds, value: "\(pbkdfRounds)")
        ]

        self.logger.debug("Signing up user \"\(uid)\".")

        self.userPool.signUp(uid, password: password, userAttributes: nil, validationData: validationData).continueWith {(task) -> Any? in
            if let error = task.error as NSError? {
                if let message = error.userInfo[Constants.ServiceError.message] as? String {
                    if message.contains(Constants.ServiceError.decodingError) {
                        completion(.failure(cause: IdentityProviderError.invalidInput))
                    } else if message.contains(Constants.ServiceError.serviceError) {
                        completion(.failure(cause: IdentityProviderError.serviceError))
                    } else {
                        completion(.failure(cause: error))
                    }
                } else {
                    completion(.failure(cause: error))
                }
            } else if let result = task.result, let userConfirmed = result.userConfirmed {
                if userConfirmed.boolValue {
                    completion(.success(uid: uid))
                } else {
                    completion(.failure(cause: IdentityProviderError.identityNotConfirmed))
                }
            } else {
                completion(RegisterResult.failure(cause: IdentityProviderError.fatalError(description: "Sign up result did not contain user confirmation status.")))
            }

            return nil
        }
    }

    public func deregister(uid: String, accessToken: String, completion: @escaping (DeregisterResult) -> Void) throws {
        let provider = AWSCognitoIdentityProvider(forKey: Constants.secureVaultServiceName)
        guard let deleteUserRequest = AWSCognitoIdentityProviderDeleteUserRequest() else {
            throw IdentityProviderError.fatalError(description: "Failed to create a delete user request.")
        }

        deleteUserRequest.accessToken = accessToken
        provider.deleteUser(deleteUserRequest).continueWith { (task) -> Any? in
            if let error = task.error {
                completion(.failure(cause: error))
                return nil
            }

            completion(.success(uid: uid))
            return nil
        }
    }

    public func signIn(uid: String, password: String, completion: @escaping (SignInResult) -> Void) throws {
        let user = self.userPool.getUser(uid)

        user.getSession(uid,
                        password: password,
                        validationData: nil,
                        clientMetaData: nil,
                        isInitialCustomChallenge: false).continueWith { (task) -> Any? in
                            if let error = task.error {
                                return completion(SignInResult.failure(cause: error))
                            } else if let result = task.result {
                                guard let idToken = result.idToken?.tokenString,
                                      let accessToken = result.accessToken?.tokenString,
                                      let refreshToken = result.refreshToken?.tokenString,
                                      let expiration = result.expirationTime else {
                                    return completion(.failure(cause: IdentityProviderError.authTokenMissing))
                                }

                                return completion(.success(tokens: AuthenticationTokens(idToken: idToken, accessToken: accessToken, refreshToken: refreshToken, lifetime: Int(floor(expiration.timeIntervalSince(Date()))))))
                            } else {
                                return completion(SignInResult.failure(cause: IdentityProviderError.fatalError(description: "Sign in completed successfully but result is missing.")))
                            }
                        }
    }

}
