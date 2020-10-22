//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

/// List of possible errors thrown by `SudoSecureVaultClient` implementation.
///
/// - alreadyRegistered: Thrown when attempting to register but the client is already registered.
/// - registerOperationAlreadyInProgress: Thrown when duplicate register calls are made.
/// - notRegistered: Indicates the client has not been registered to the
///     Sudo platform backend.
/// - notSignedIn: Indicates the API being called requires the client to sign in.
/// - invalidConfig: Indicates the configuration dictionary passed to initialize the client was not valid.
/// - authTokenMissing: Thrown when required authentication tokens were not return by Secure Vault service.
/// - notAuthorized: Indicates the authentication failed. Likely due to incorrect private key, the identity
///     being removed from the backend or significant clock skew between the client and the backend.
/// - invalidInput: Indicates the input to the API was invalid.
/// - serviceError: Indicates that an internal server error caused the operation to fail. The error is
///     possibly transient and retrying at a later time may cause the operation to complete
///     successfully
/// - graphQLError: Indicates that a GraphQL error was returned by the backend.
/// - fatalError: Indicates that a fatal error occurred. This could be due to
///     coding error, out-of-memory condition or other conditions that is
///     beyond control of `SudoSecureVaultClient` implementation.
public enum SudoSecureVaultClientError: Error {
    case alreadyRegistered
    case registerOperationAlreadyInProgress
    case notRegistered
    case notSignedIn
    case invalidConfig
    case authTokenMissing
    case notAuthorized
    case invalidInput
    case serviceError
    case graphQLError(description: String)
    case fatalError(description: String)
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
public protocol SudoSecureVaultClient: class {

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
