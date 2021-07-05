//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SudoLogging
import SudoKeyManager
import AWSAppSync
import CommonCrypto
import SudoApiClient

/// Operation to retrieve metadata for all vaults owned by the user.
class ListVaultsMetadataOnly: SecureVaultOperation {

    private unowned let graphQLClient: SudoApiClient

    public var vaults: [VaultMetadata] = []

    /// Initializes and returns a `ListMetadataOnlyVaults` operation.
    ///
    /// - Parameters:
    ///
    ///   - graphQLClient: GraphQL client used to make backend API calls.
    ///   - logger: Logger used for logging.
    init(
        graphQLClient: SudoApiClient,
        logger: Logger = Logger.sudoSecureVaultLogger
    ) {
        self.graphQLClient = graphQLClient
        super.init(logger: logger)
    }

    override func execute() {
        do {
            try self.graphQLClient.fetch(
                query: ListVaultsMetadataOnlyQuery(),
                cachePolicy: .fetchIgnoringCacheData,
                resultHandler: { (result, error) in
                    if let error = error {
                        self.error = SudoSecureVaultClientError.fromApiOperationError(error: error)
                        return self.done()
                    }

                    guard let result = result else {
                        self.error = SudoSecureVaultClientError.fatalError(description: "Query completed successfully but result is missing.")
                        return self.done()
                    }

                    if let error = result.errors?.first {
                        self.error = SudoSecureVaultClientError.fromApiOperationError(error: error)
                        return self.done()
                    }

                    guard let items = result.data?.listVaultsMetadataOnly?.items else {
                        self.error = SudoSecureVaultClientError.fatalError(description: "Query result contained no list data.")
                        return self.done()
                    }

                    for item in items {
                        self.vaults.append(
                            VaultMetadata(
                                id: item.id,
                                owner: item.owner,
                                version: item.version,
                                blobFormat: item.blobFormat,
                                createdAt: Date(millisecondsSinceEpoch: item.createdAtEpochMs),
                                updatedAt: Date(millisecondsSinceEpoch: item.updatedAtEpochMs),
                                owners: item.owners.map({ Owner(id: $0.id, issuer: $0.issuer) })
                            )
                        )
                    }

                    self.done()
                }
            )
        } catch {
            self.error = SudoSecureVaultClientError.fromApiOperationError(error: error)
            self.done()
        }
    }

}
