//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SudoLogging
import SudoKeyManager
import AWSAppSync
import CommonCrypto

/// Operation to retrieve metadata for all vaults owned by the user.
class ListVaultsMetadataOnly: SecureVaultOperation {

    private unowned let graphQLClient: AWSAppSyncClient

    public var vaults: [VaultMetadata] = []

    /// Initializes and returns a `ListMetadataOnlyVaults` operation.
    ///
    /// - Parameters:
    ///
    ///   - graphQLClient: GraphQL client used to make backend API calls.
    ///   - logger: Logger used for logging.
    init(graphQLClient: AWSAppSyncClient,
         logger: Logger = Logger.sudoSecureVaultLogger) {
        self.graphQLClient = graphQLClient
        super.init(logger: logger)
    }

    override func execute() {
        self.graphQLClient.fetch(query: ListVaultsMetadataOnlyQuery(), cachePolicy: .fetchIgnoringCacheData) { (result, error) in
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

            guard let items = result.data?.listVaultsMetadataOnly?.items else {
                self.error = SudoSecureVaultClientError.fatalError(description: "Query result contained no list data.")
                return self.done()
            }

            for item in items {
                self.vaults.append(VaultMetadata(id: item.id, owner: item.owner, version: item.version, blobFormat: item.blobFormat, createdAt: Date(millisecondsSinceEpoch: item.createdAtEpochMs), updatedAt: Date(millisecondsSinceEpoch: item.updatedAtEpochMs), owners: item.owners.map({ Owner(id: $0.id, issuer: $0.issuer) })))
            }

            self.done()
        }
    }

}
