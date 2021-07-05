//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// List of possible errors thrown by `IdentityProvider`.
///
/// - invalidConfig: Indicates the configuration dictionary passed to initialize
///     the provider was not valid.
/// - invalidInput: Indicates bad input was provided to the API call.
/// - identityNotConfirmed: identity is not confirmed hence cannot sign in yet.
/// - alreadyRegistered: identity is already registered..
/// - notAuthorized: Indicates the authentication failed. Likely due to incorrect private key, the identity
///     being removed from the backend or significant clock skew between the client and the backend.
/// - notSignedIn: Indicates the API failed because the user is not signed-in.
/// - authTokenMissing: Thrown when required authentication tokens were not returned by Secure Vault service.
/// - serviceError: Indicates that an internal server error occurred. Retrying at a later time may succeed.
/// - fatalError: Indicates that a fatal error occurred. This could be due to
///     coding error, out-of-memory condition or other conditions that is
///     beyond control of `IdentityProvider` implementation.
public enum IdentityProviderError: Error {
    case invalidConfig
    case invalidInput
    case identityNotConfirmed
    case alreadyRegistered
    case notAuthorized
    case notSignedIn
    case authTokenMissing
    case serviceError
    case fatalError(description: String)
}

/// Encapsulates interface requirements for an external identity provider to register and
/// authenticate an identity within Sudo platform ecosystem.
public protocol IdentityProvider: AnyObject {

    /// Registers a new identity (user) against the identity provider.
    ///
    /// - Parameters:
    ///   - uid: ID of the identity (user).
    ///   - password: Password to use for subsequent sign in.
    ///   - token: ID token from Identity Service.
    ///   - authenticationSalt: Authentication salt.
    ///   - encryptionSalt: Encryption salt.
    ///   - pbkdfRounds: PBKDF rounds.
    ///   - completion: The completion handler to invoke to pass the newly created user Id or error.
    func register(uid: String,
                  password: String,
                  token: String,
                  authenticationSalt: String,
                  encryptionSalt: String,
                  pbkdfRounds: UInt32,
                  completion: @escaping (Swift.Result<String, Error>) -> Void) throws

    /// Sign into the identity provider.
    ///
    /// - Parameters:
    ///   - uid: ID of the identity (user) to sign in.
    ///   - password: Password.
    ///   - completion: The completion handler to invoke to pass the authentication tokens or error.
    func signIn(uid: String,
                password: String,
                completion: @escaping (Swift.Result<AuthenticationTokens, Error>) -> Void) throws

    /// Change the user's password.
    ///
    /// - Parameters:
    ///   - uid: ID of the identity (user).
    ///   - oldPassword: Old password.
    ///   - newPassword: New password..
    ///   - completion: The completion handler to invoke to pass the user ID or error.
    func changePassword(uid: String,
                        oldPassword: String,
                        newPassword: String,
                        completion: @escaping (Swift.Result<String, Error>) -> Void) throws

}
