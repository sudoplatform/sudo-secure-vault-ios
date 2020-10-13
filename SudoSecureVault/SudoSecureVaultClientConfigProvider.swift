//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSAppSync

/// `AWSAppSyncServiceConfigProvider` implementation that converts Sudo platform
/// configuration to AWS AppSync configuration.
public struct SudoSecureVaultClientConfigProvider: AWSAppSyncServiceConfigProvider {

    public struct Config {
        // AWS region hosting identity verification service.
        static let region = "region"
        // API URL.
        static let apiUrl = "apiUrl"
    }

    public let clientDatabasePrefix: String? = nil

    public let endpoint: URL

    public let region: AWSRegionType

    public let authType: AWSAppSyncAuthType = .amazonCognitoUserPools

    public let apiKey: String? = nil

    /// Initializes `SudoSecureVaultClientConfigProvider` with the API endpoint URL
    /// and AWS region type.
    ///
    /// - Parameters:
    ///   - endpoint: URL for the  Secure Vault service's GraphQL API endpoint.
    ///   - region: AWS region.
    public init(endpoint: URL, region: AWSRegionType) {
        self.endpoint = endpoint
        self.region = region
    }

    /// Initializes `SudoSecureVaultClientConfigProvider` with the API endpoint URL
    /// and AWS region type.
    ///
    /// - Parameter config: Configuration parameters for Secure Vault service GraphQL API endpoint.
    public init?(config: [String: Any]) {
        guard let apiUrl = config[Config.apiUrl] as? String,
            let endpoint = URL(string: apiUrl),
            let region = config[Config.region] as? String else {
                return nil
        }

        guard let regionType = AWSEndpoint.regionTypeFrom(name: region) else {
            return nil
        }

        self.init(endpoint: endpoint, region: regionType)
    }

}
