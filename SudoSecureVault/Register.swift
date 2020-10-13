//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoLogging
import AWSCognitoIdentityProvider
import SudoKeyManager

/// List of possible errors returned by `RegisterOperation`.
///
/// - identityNotConfirmed: identity is not confirmed hence cannot sign in yet.
/// - fatalError: Indicates that a fatal error occurred. This could be due to
///     coding error, out-of-memory condition or other conditions that is
///     beyond control of `RegisterOperation` implementation.
public enum RegisterOperationError: Error {
    case identityNotConfirmed
    case fatalError(description: String)
}

/// Performs register operation.
class Register: SecureVaultOperation {

    /// ID of the identity (user) to register.
    public let uid: String

    private let password: String

    private let token: String

    private let authenticationSalt: String

    private let encryptionSalt: String

    private let pbkdfRounds: UInt32

    private unowned let identityProvider: IdentityProvider

    /// Initializes and returns a `Register` operation.
    ///
    /// - Parameters:
    ///   - uid: User ID.
    ///   - password: Password.
    ///   - token: ID token from Identity Service.
    ///   - authenticationSalt: Authentication salt.
    ///   - encryptionSalt: Encryption salt.
    ///   - pbkdfRounds: PBKDF rounds.
    ///   - identityProvider: Identity provider to register against.
    ///   - logger: Logger used for logging.
    init(uid: String,
         password: String,
         token: String,
         authenticationSalt: String,
         encryptionSalt: String,
         pbkdfRounds: UInt32,
         identityProvider: IdentityProvider,
         logger: Logger = Logger.sudoSecureVaultLogger) {
        self.identityProvider = identityProvider
        self.uid = uid
        self.password = password
        self.token = token
        self.authenticationSalt = authenticationSalt
        self.encryptionSalt = encryptionSalt
        self.pbkdfRounds = pbkdfRounds
        super.init(logger: logger)
    }

    override func execute() {
        self.logger.info("Performing sign-up.")

        do {
            try self.identityProvider.register(uid: self.uid, password: self.password, token: self.token, authenticationSalt: self.authenticationSalt, encryptionSalt: self.encryptionSalt, pbkdfRounds: self.pbkdfRounds) { (result) in
                defer {
                    self.done()
                }

                switch result {
                case let .success(uid):
                    self.logger.info("\(uid) registered successfully.")
                case let .failure(cause):
                    self.error = cause
                }
            }
        } catch let error {
            self.error = error
            self.done()
        }
    }

}
