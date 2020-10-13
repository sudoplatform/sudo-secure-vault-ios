//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SudoLogging

/// Operation to sign in.
class SignIn: SecureVaultOperation {

    private struct Constants {

        struct Output {
            static let token = "token"
        }

    }

    private unowned let identityProvider: IdentityProvider

    private let uid: String

    private let password: String

    var tokens: AuthenticationTokens?

    /// Initializes and returns a `SignIn` operation.
    ///
    /// - Parameters:
    ///
    ///   - uid: User ID.
    ///   - password: Password.
    ///   - identityProvider: Identity provider to use for signing in.
    ///   - logger: Logger used for logging.
    init(uid: String,
         password: String,
         identityProvider: IdentityProvider,
         logger: Logger = Logger.sudoSecureVaultLogger) {
        self.uid = uid
        self.password = password
        self.identityProvider = identityProvider
        super.init(logger: logger)
    }

    override func execute() {
        do {
            try self.identityProvider.signIn(uid: self.uid, password: self.password) { (result) in
                defer {
                    self.done()
                }

                switch result {
                case let .success(tokens):
                    self.output[Constants.Output.token] = tokens.idToken
                    self.tokens = tokens
                case let .failure(cause):
                    switch cause {
                    case IdentityProviderError.notAuthorized:
                        self.error = SudoSecureVaultClientError.notAuthorized
                    default:
                        self.error = cause
                    }
                }
            }
        } catch {
            self.error = error
            self.done()
        }
    }

}
