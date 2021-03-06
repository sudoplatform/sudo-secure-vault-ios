//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SudoLogging
import AWSAppSync
import SudoKeyManager
import SudoApiClient

/// Operation to create a new vault.
class CreateVault: SecureVaultOperation {

    private struct Constants {

        struct Input {
            static let token = "token"
        }

        static let encryptionMethod = "AES/CBC/PKCS7Padding"

    }

    private unowned let graphQLClient: SudoApiClient

    private let keyManager: SudoKeyManager

    private let key: Data

    private let token: String?

    private let blob: Data

    private let blobFormat: String

    private let ownershipProofs: [String]

    public var vaultMetadata: VaultMetadata?

    /// Initializes and returns a `CreateVault` operation.
    ///
    /// - Parameters:
    ///
    ///   - token: ID token issued by Secure Vault authentication provider.
    ///   - key: Encryption key.
    ///   - blob: Blob to encrypt and store.
    ///   - blobFormat: Specifier for the format/structure of information represented in the blob.
    ///   - ownershipProofs: List of ownership proofs.
    ///   - keyManager: KeyManager to use for cryptographic operations.
    ///   - graphQLClient: GraphQL client used to make backend API calls.
    ///   - logger: Logger used for logging.
    init(
        token: String? = nil,
        key: Data,
        blob: Data,
        blobFormat: String,
        ownershipProofs: [String],
        keyManager: SudoKeyManager,
        graphQLClient: SudoApiClient,
        logger: Logger = Logger.sudoSecureVaultLogger
    ) {
        self.token = token
        self.key = key
        self.blob = blob
        self.blobFormat = blobFormat
        self.ownershipProofs = ownershipProofs
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

        let input = CreateVaultInput(
            token: token,
            blob: encrypted.base64EncodedString(),
            blobFormat: self.blobFormat,
            encryptionMethod: Constants.encryptionMethod,
            ownershipProofs: self.ownershipProofs
        )

        do {
        try self.graphQLClient.perform(
            mutation: CreateVaultMutation(input: input),
            resultHandler: { (result, error) in
                if let error = error {
                    self.error = SudoSecureVaultClientError.fromApiOperationError(error: error)
                    return self.done()
                }

                guard let result = result else {
                    self.error = SudoSecureVaultClientError.fatalError(description: "Mutation completed successfully but result is missing.")
                    return self.done()
                }

                if let error = result.errors?.first {
                    self.error = SudoSecureVaultClientError.fromApiOperationError(error: error)
                    return self.done()
                }

                guard let createVault = result.data?.createVault else {
                    self.error = SudoSecureVaultClientError.fatalError(description: "Mutation result did not contain required object.")
                    return self.done()
                }
                self.vaultMetadata = VaultMetadata(
                    id: createVault.id,
                    owner: createVault.owner,
                    version: createVault.version,
                    blobFormat: createVault.blobFormat,
                    createdAt: Date(millisecondsSinceEpoch: createVault.createdAtEpochMs),
                    updatedAt: Date(millisecondsSinceEpoch: createVault.updatedAtEpochMs),
                    owners: createVault.owners.map({ Owner(id: $0.id, issuer: $0.issuer) })
                )

                self.done()
            })
        } catch {
            self.error = SudoSecureVaultClientError.fromApiOperationError(error: error)
            self.done()
        }
    }

}
