//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SudoLogging
import SudoKeyManager
import AWSAppSync
import SudoApiClient

/// Operation to degister an exising vault user.
class Deregister: SecureVaultOperation {

    private unowned let graphQLClient: SudoApiClient

    var uid: String?

    /// Initializes and returns a `Deregister` operation.
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
            try self.graphQLClient.perform(
                mutation: DeregisterMutation(),
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

                    guard let deregister = result.data?.deregister else {
                        self.error = SudoSecureVaultClientError.fatalError(description: "Mutation result did not contain required object.")
                        return self.done()
                    }

                    self.uid = deregister.username
                    self.done()
                }
            )
        } catch {
            self.error = SudoSecureVaultClientError.fromApiOperationError(error: error)
            self.done()
        }
    }

}
