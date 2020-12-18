//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SudoLogging
import SudoKeyManager
import AWSAppSync

/// Operation to delete an existing vault.
class DeleteVault: SecureVaultOperation {

    private unowned let graphQLClient: AWSAppSyncClient

    private let guid: String

    public var vaultMetadata: VaultMetadata?

    /// Initializes and returns a `DeleteVault` operation.
    ///
    /// - Parameters:
    ///
    ///   - id: Vault ID.
    ///   - graphQLClient: GraphQL client used to make backend API calls.
    ///   - logger: Logger used for logging.
    init(id: String,
         graphQLClient: AWSAppSyncClient,
         logger: Logger = Logger.sudoSecureVaultLogger) {
        self.guid = id
        self.graphQLClient = graphQLClient
        super.init(logger: logger)
    }

    override func execute() {
        let input = DeleteVaultInput(id: self.guid)
        self.graphQLClient.perform(mutation: DeleteVaultMutation(input: input), resultHandler: { (result, error) in
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

            guard let updateVault = result.data?.deleteVault else {
                self.error = SudoSecureVaultClientError.fatalError(description: "Mutation result did not contain required object.")
                return self.done()
            }
            self.vaultMetadata = VaultMetadata(id: updateVault.id, owner: updateVault.owner, version: updateVault.version, blobFormat: updateVault.blobFormat, createdAt: Date(millisecondsSinceEpoch: updateVault.createdAtEpochMs), updatedAt: Date(millisecondsSinceEpoch: updateVault.updatedAtEpochMs), owners: updateVault.owners.map({ Owner(id: $0.id, issuer: $0.issuer) }))

            self.done()
        })
    }

}
