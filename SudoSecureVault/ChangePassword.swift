//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SudoLogging

/// Operation to change the vault user's password.
class ChangePassword: SecureVaultOperation {

    private unowned let identityProvider: IdentityProvider

    private let uid: String

    private let oldPassword: String

    private let newPassword: String

    /// Initializes and returns a `ChangePassword` operation.
    ///
    /// - Parameters:
    ///
    ///   - uid: User ID.
    ///   - oldPassword: Old password.
    ///   - newPassword: New password.
    ///   - identityProvider: Identity provider to use for signing in.
    ///   - logger: Logger used for logging.
    init(uid: String,
         oldPassword: String,
         newPassword: String,
         identityProvider: IdentityProvider,
         logger: Logger = Logger.sudoSecureVaultLogger) {
        self.uid = uid
        self.oldPassword = oldPassword
        self.newPassword = newPassword
        self.identityProvider = identityProvider
        super.init(logger: logger)
    }

    override func execute() {
        do {
            try self.identityProvider.changePassword(uid: self.uid, oldPassword: self.oldPassword, newPassword: self.newPassword) { (result) in
                defer {
                    self.done()
                }

                switch result {
                case .success:
                    break
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
