//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SudoLogging
import SudoKeyManager
import AWSAppSync
import CommonCrypto

/// Operation to retrieve all vaults owned by the user.
class ListVaults: SecureVaultOperation {

    private struct Constants {

        struct Input {
            static let token = "token"
        }

        public static let defaultBlockSizeAES = kCCBlockSizeAES128

    }

    private unowned let graphQLClient: AWSAppSyncClient

    private let keyManager: SudoKeyManager

    private let token: String?

    private let key: Data

    public var vaults: [Vault] = []

    /// Initializes and returns a `ListVaults` operation.
    ///
    /// - Parameters:
    ///
    ///   - token: ID token issued by Secure Vault authentication provider.
    ///   - key: Encryption key.
    ///   - keyManager: KeyManager to use for cryptographic operations.
    ///   - graphQLClient: GraphQL client used to make backend API calls.
    ///   - logger: Logger used for logging.
    init(token: String? = nil,
         key: Data,
         keyManager: SudoKeyManager,
         graphQLClient: AWSAppSyncClient,
         logger: Logger = Logger.sudoSecureVaultLogger) {
        self.token = token
        self.key = key
        self.keyManager = keyManager
        self.graphQLClient = graphQLClient
        super.init(logger: logger)
    }

    override func execute() {
        guard let token = self.token ?? self.input[Constants.Input.token] as? String else {
            self.error = SudoSecureVaultClientError.fatalError(description: "Expected authentication token not found in the input.")
            return self.done()
        }

        self.graphQLClient.fetch(query: ListVaultsQuery(token: token), cachePolicy: .fetchIgnoringCacheData) { (result, error) in
            if let error = error {
                self.error = error
                return self.done()
            }

            guard let result = result else {
                self.error = SudoSecureVaultClientError.fatalError(description: "Query completed successfully but result is missing.")
                return self.done()
            }

            if let error = result.errors?.first {
                let message = "Failed to list vaults: \(error)"
                self.logger.error(message)

                if let errorType = error[SecureVaultOperation.SecureVaultServiceError.type] as? String {
                    switch errorType {
                    case SecureVaultOperation.SecureVaultServiceError.serviceError:
                        self.error = SudoSecureVaultClientError.serviceError
                    default:
                        self.error = SudoSecureVaultClientError.graphQLError(description: message)
                    }
                } else {
                    self.error = SudoSecureVaultClientError.graphQLError(description: message)
                }

                return self.done()
            }

            guard let items = result.data?.listVaults?.items else {
                self.error = SudoSecureVaultClientError.fatalError(description: "Query result contained no list data.")
                return self.done()
            }

            for item in items {
                guard let vault = Data(base64Encoded: item.blob) else {
                    self.error = SudoSecureVaultClientError.fatalError(description: "Failed to decode vault.")
                    return self.done()
                }

                let blob: Data
                do {
                    guard vault.count >= Constants.defaultBlockSizeAES + 16 else {
                        self.error = SudoSecureVaultClientError.fatalError(description: "Vault is invalid.")
                        return self.done()
                    }

                    let encryptedData = vault[0..<vault.count - 16]
                    let iv = vault[vault.count - 16..<vault.count]
                    blob = try self.keyManager.decryptWithSymmetricKey(self.key, data: encryptedData, iv: iv)
                } catch {
                    self.error = error
                    return self.done()
                }

                self.vaults.append(Vault(id: item.id, owner: item.owner, version: item.version, blobFormat: item.blobFormat, createdAt: Date(millisecondsSinceEpoch: item.createdAtEpochMs), updatedAt: Date(millisecondsSinceEpoch: item.updatedAtEpochMs), owners: item.owners.map({ Owner(id: $0.id, issuer: $0.issuer) }), blob: blob))
            }

            self.done()
        }
    }

}
