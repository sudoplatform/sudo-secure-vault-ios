//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SudoApiClient

public enum SudoSecureVaultClientError: Error {

    /// Indicates that an attempt to register was made but the client is already registered.
    case alreadyRegistered

    /// Indicates that an attempt to register was made but there's already one in progress.
    case registerOperationAlreadyInProgress

    /// Indicates the client has not been registered to the Sudo platform backend.
    case notRegistered

    /// Indicates the ownership proof provided for the new vault was invalid.
    case invalidOwnershipProofError

    /// Indicates the required authentication tokens were not returned by Secure Vault Service.
    case authTokenMissing

    /// Indicates that the configuration dictionary passed to initialize the client was not valid.
    case invalidConfig

    /// Indicates the configuration related to Secure Vault Service is not found. This may indicate that Secure Vault
    /// Service is not deployed into your runtime instance or the config file that you are using is invalid..
    case secureVaultServiceConfigNotFound

    /// Indicates that the input to the API was invalid.
    case invalidInput

    /// Indicates the requested operation failed because the user account is locked.
    case accountLocked

    /// Indicates the API being called requires the client to sign in.
    case notSignedIn

    /// Indicates that the request operation failed due to authorization error. This maybe due to the authentication
    /// token being invalid or other security controls that prevent the user from accessing the API.
    case notAuthorized

    /// Indicates API call failed due to it requiring tokens to be refreshed but something else is already in
    /// middle of refreshing the tokens.
    case refreshTokensOperationAlreadyInProgress

    /// Indicates API call  failed due to it exceeding some limits imposed for the API. For example, this error
    /// can occur if the vault size was too big.
    case limitExceeded

    /// Indicates that the user does not have sufficient entitlements to perform the requested operation.
    case insufficientEntitlements

    /// Indicates the version of the vault that is getting updated does not match the current version of the vault stored
    /// in the backend. The caller should retrieve the current version of the vault and reconcile the difference.
    case versionMismatch

    /// Indicates that an internal server error caused the operation to fail. The error is possibly transient and
    /// retrying at a later time may cause the operation to complete successfully
    case serviceError

    /// Indicates that the request failed due to connectivity, availability or access error.
    case requestFailed(response: HTTPURLResponse?, cause: Error?)

    /// Indicates that there were too many attempts at sending API requests within a short period of time.
    case rateLimitExceeded

    /// Indicates that a GraphQL error was returned by the backend.
    case graphQLError(description: String)

    /// Indicates that a fatal error occurred. This could be due to coding error, out-of-memory condition or other
    /// conditions that is beyond control of `SudoSecureVaultClient` implementation.
    case fatalError(description: String)
}

extension SudoSecureVaultClientError {

    struct Constants {
        static let errorType = "errorType"
        static let invalidOwnershipProofError = "sudoplatform.vault.InvalidOwnershipProofError"
        static let notAuthorizedError = "sudoplatform.vault.NotAuthorizedError"
        static let tokenValidationError = "sudoplatform.vault.TokenValidationError"
    }

    static func fromApiOperationError(error: Error) -> SudoSecureVaultClientError {
        switch error {
        case ApiOperationError.accountLocked:
            return .accountLocked
        case ApiOperationError.notSignedIn:
            return .notSignedIn
        case ApiOperationError.notAuthorized:
            return .notAuthorized
        case ApiOperationError.refreshTokensOperationAlreadyInProgress:
            return .refreshTokensOperationAlreadyInProgress
        case ApiOperationError.limitExceeded:
            return .limitExceeded
        case ApiOperationError.insufficientEntitlements:
            return .insufficientEntitlements
        case ApiOperationError.serviceError:
            return .serviceError
        case ApiOperationError.versionMismatch:
            return .versionMismatch
        case ApiOperationError.invalidRequest:
            return .invalidInput
        case ApiOperationError.rateLimitExceeded:
            return .rateLimitExceeded
        case ApiOperationError.graphQLError(let cause):
            guard let errorType = cause[Constants.errorType] as? String else {
              return .fatalError(description: "GraphQL operation failed but error type was not found in the response. \(error)")
            }

            switch errorType {
            case Constants.invalidOwnershipProofError:
                return .invalidOwnershipProofError
            case Constants.notAuthorizedError, Constants.tokenValidationError:
                return .notAuthorized
            default:
                return .graphQLError(description: "Unexpected GraphQL error: \(cause)")
            }
        case ApiOperationError.requestFailed(let response, let cause):
            return .requestFailed(response: response, cause: cause)
        default:
            return .fatalError(description: "Unexpected API operation error: \(error)")
        }
    }

}
/// Data required to initialize the client.
public struct InitializationData {
    public init(owner: String, authenticationSalt: Data, encryptionSalt: Data, pbkdfRounds: Int) {
        self.owner = owner
        self.authenticationSalt = authenticationSalt
        self.encryptionSalt = encryptionSalt
        self.pbkdfRounds = pbkdfRounds
    }

    public let owner: String
    public let authenticationSalt: Data
    public let encryptionSalt: Data
    public let pbkdfRounds: Int
}

/// Vault owner.
public struct Owner {
    public init(id: String, issuer: String) {
        self.id = id
        self.issuer = issuer
    }

    public let id: String
    public let issuer: String
}

/// Object metadata protocol..
public protocol Metadata {
    /// Unique ID.
    var id: String { get }

    /// Vault owner (User).
    var owner: String { get }

    /// Object version.
    var version: Int { get }

    /// Blob format specifier.
    var blobFormat: String { get }

    /// Date/time at which the vault was created.
    var createdAt: Date { get }

    /// Date/time at which the vault was last modified.
    var updatedAt: Date { get }

    /// List of vault owners.
    var owners: [Owner] { get }
}

/// Vault metadata.
public struct VaultMetadata: Metadata {
    public init(id: String, owner: String, version: Int, blobFormat: String, createdAt: Date, updatedAt: Date, owners: [Owner]) {
        self.id = id
        self.owner = owner
        self.version = version
        self.blobFormat = blobFormat
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.owners = owners
    }

    public let id: String

    public let owner: String

    public let version: Int

    public let blobFormat: String

    public let createdAt: Date

    public let updatedAt: Date

    public let owners: [Owner]

}

/// Vault.
public struct Vault: Metadata {
    public init(id: String, owner: String, version: Int, blobFormat: String, createdAt: Date, updatedAt: Date, owners: [Owner], blob: Data) {
        self.id = id
        self.owner = owner
        self.version = version
        self.blobFormat = blobFormat
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.owners = owners
        self.blob = blob
    }

    public let id: String

    public let owner: String

    public let version: Int

    public let blobFormat: String

    public let createdAt: Date

    public let updatedAt: Date

    public let owners: [Owner]

    /// Blob stored securely in the vault.
    public let blob: Data

}

/// Protocol encapsulating a library of functions for calling Sudo Platform
/// Secure Vault service, managing keys, performing cryptographic operations.
public protocol SudoSecureVaultClient: AnyObject {

    /// The release version of this instance of `SudoSecureVaultClient`.
    var version: String { get }

    /// Determines whether or not a Secure Vault user has been registered.
    ///
    /// - Returns: `true` if the user is registered.
    func isRegistered(completion: @escaping (Result<Bool, Error>) -> Void) throws

    /// Resets internal state and clear any cached data.
    ///
    /// - Throws: `SudoSecureVaultClientError.FatalError`
    func reset() throws

    /// Registers this client against the backend.
    ///
    /// - Parameters:
    ///   - key: Key deriving key.
    ///   - password: Vault password.
    ///   - completion: The completion handler to invoke to pass the newly registered user ID or error
    func register(key: Data,
                  password: Data,
                  completion: @escaping (Result<String, Error>) -> Void) throws

    /// Returns the initialization data. If the client has a cached copy then the cached initialization data will be
    /// returned otherwise it will be fetched from the backend. This is mainly used for testing and the consuming
    /// app is not expected to use this method.
    ///
    /// - Parameter completion: The completion handler to invoke to pass the initialization data if one exists or error.
    func getInitializationData(completion: @escaping (Result<InitializationData?, Error>) -> Void) throws

    /// Deregisters the vault user associated with this client.
    ///
    /// - Parameter completion: The completion handler to invoke to pass the deregistered user ID or error.
    func deregister(completion: @escaping (Result<String, Error>) -> Void) throws

    /// Creates a new vault.
    ///
    /// - Parameters:
    ///   - key: Key deriving key.
    ///   - password: Vault password.
    ///   - blob:  Blob to encrypt and store.
    ///   - blobFormat: Specifier for the format/structure of information represented in the blob.
    ///   - ownershipProof: Ownership proof of the Sudo to be associate with the vault. The ownership proof
    ///                     must contain audience of "sudoplatform.secure-vault.vault".
    ///   - completion: The completion handler to invoke to pass the created vault's metadata or error.
    func createVault(
        key: Data,
        password: Data,
        blob: Data,
        blobFormat: String,
        ownershipProof: String,
        completion: @escaping (Result<VaultMetadata, Error>) -> Void
    ) throws

    /// Updates an existing vault.
    ///
    /// - Parameters:
    ///   - key: Key deriving key.
    ///   - password: Vault password.
    ///   - id: Vault ID.
    ///   - blob:  Blob to encrypt and store.
    ///   - blobFormat: Specifier for the format/structure of information represented in the blob.
    ///   - completion: The completion handler to invoke to pass the updated vault's metadata or error.
    func updateVault(
        key: Data,
        password: Data,
        id: String,
        version: Int,
        blob: Data,
        blobFormat: String,
        completion: @escaping (Result<VaultMetadata, Error>) -> Void
    ) throws

    /// Deletes an existing vault.
    ///
    /// - Parameters:
    ///   - id: Vault ID.
    ///   - completion: The completion handler to invoke to pass the updated vault's metadata or error.
    func deleteVault(id: String, completion: @escaping (Result<VaultMetadata?, Error>) -> Void) throws

    /// Retrieve a single vault matching the specified ID.
    ///
    /// - Parameters:
    ///   - key: Key deriving key.
    ///   - password: Vault password.
    ///   - id: Vault ID.
    ///   - completion: The completion handler to invoke to pass the retrieved vault if exists or error.
    func getVault(
        key: Data,
        password: Data,
        id: String,
        completion: @escaping (Result<Vault?, Error>) -> Void
    ) throws

    /// Retrieves all vaults owned by the authenticated user.
    ///
    /// - Parameters:
    ///   - key: Key deriving key.
    ///   - password: Vault password.
    ///   - completion: The completion handler to invoke to pass the retrieved vaults or error.
    func listVaults(key: Data, password: Data, completion: @escaping (Result<[Vault], Error>) -> Void) throws

    /// Retrieves metadata for all vaults. This can be used to determine if any vault was
    /// updated without requiring the extra authentication and decryption.
    ///
    /// - Parameters:
    ///   - completion: The completion handler to invoke to pass the retrieved vaults metedata or error.
    func listVaultsMetadataOnly(completion: @escaping (Result<[VaultMetadata], Error>) -> Void) throws

    /// Changes the vault password. Existing vaults will be downloaded, re-encrypted and
    /// uploaded so this API may take some time to complete.
    ///
    /// - Parameters:
    ///   - key: Key deriving key.
    ///   - oldPassword: Old vault password.
    ///   - newPassword: New vault password.
    ///   - completion: The completion handler to invoke to indicate success or pass an error.
    func changeVaultPassword(
        key: Data,
        oldPassword: Data,
        newPassword: Data,
        completion: @escaping (Result<Void, Error>) -> Void
    ) throws

}
