//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SudoLogging
import SudoKeyManager
import AWSAppSync

/// Operation to update an existing vault.
class UpdateVault: SecureVaultOperation {

    private struct Constants {

        struct Input {
            static let token = "token"
        }

        static let encryptionMethod = "AES/CBC/PKCS7Padding"

    }

    private unowned let graphQLClient: AWSAppSyncClient

    private let keyManager: SudoKeyManager

    private let key: Data

    private let token: String?

    private let guid: String

    private let expectedVersion: Int

    private let blob: Data

    private let blobFormat: String

    public var vaultMetadata: VaultMetadata?

    /// Initializes and returns a `UpdateVault` operation.
    ///
    /// - Parameters:
    ///
    ///   - token: ID token issued by Secure Vault authentication provider.
    ///   - key: Encryption key.
    ///   - id: Vault ID.
    ///   - expectedVersion: Expected object version.
    ///   - blob:  Blob to encrypt and store.
    ///   - blobFormat: Specifier for the format/structure of information represented in the blob.
    ///   - keyManager: KeyManager to use for cryptographic operations.
    ///   - graphQLClient: GraphQL client used to make backend API calls.
    ///   - logger: Logger used for logging.
    init(token: String? = nil,
         key: Data,
         id: String,
         expectedVersion: Int,
         blob: Data,
         blobFormat: String,
         keyManager: SudoKeyManager,
         graphQLClient: AWSAppSyncClient,
         logger: Logger = Logger.sudoSecureVaultLogger) {
        self.token = token
        self.key = key
        self.guid = id
        self.expectedVersion = expectedVersion
        self.blob = blob
        self.blobFormat = blobFormat
        self.keyManager = keyManager
        self.graphQLClient = graphQLClient
        super.init(logger: logger)
    }

    override func execute() {
        guard let token = self.token ?? self.input[Constants.Input.token] as? String else {
            self.error = SudoSecureVaultClientError.fatalError(description: "Expected authentication token not found in the input.")
            return self.done()
        }

        let encrypted: Data
        do {
            let iv = try self.keyManager.createIV()
            let encryptedData = try self.keyManager.encryptWithSymmetricKey(key, data: self.blob, iv: iv)
            encrypted = encryptedData + iv
        } catch {
            self.error = error
            return self.done()
        }

        let input = UpdateVaultInput(token: token, id: self.guid, expectedVersion: self.expectedVersion, blob: encrypted.base64EncodedString(), blobFormat: self.blobFormat, encryptionMethod: Constants.encryptionMethod)
        self.graphQLClient.perform(mutation: UpdateVaultMutation(input: input), resultHandler: { (result, error) in
            if let error = error {
                self.error = error
                return self.done()
            }

            guard let result = result else {
                self.error = SudoSecureVaultClientError.fatalError(description: "Mutation completed successfully but result is missing.")
                return self.done()
            }

            if let error = result.errors?.first {
                self.error = self.graphQLErrorToClientError(error: error)
                return self.done()
            }

            guard let updateVault = result.data?.updateVault else {
                self.error = SudoSecureVaultClientError.fatalError(description: "Mutation result did not contain required object.")
                return self.done()
            }
            self.vaultMetadata = VaultMetadata(id: updateVault.id, owner: updateVault.owner, version: updateVault.version, blobFormat: updateVault.blobFormat, createdAt: Date(millisecondsSinceEpoch: updateVault.createdAtEpochMs), updatedAt: Date(millisecondsSinceEpoch: updateVault.updatedAtEpochMs), owners: updateVault.owners.map({ Owner(id: $0.id, issuer: $0.issuer) }))

            self.done()
        })
    }

}
