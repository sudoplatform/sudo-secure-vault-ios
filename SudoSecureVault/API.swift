//  This file was automatically generated and should not be edited.

import AWSAppSync

public struct CreateVaultInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(token: String, blob: String, blobFormat: String, encryptionMethod: String, ownershipProofs: [String]) {
    graphQLMap = ["token": token, "blob": blob, "blobFormat": blobFormat, "encryptionMethod": encryptionMethod, "ownershipProofs": ownershipProofs]
  }

  public var token: String {
    get {
      return graphQLMap["token"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "token")
    }
  }

  public var blob: String {
    get {
      return graphQLMap["blob"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "blob")
    }
  }

  public var blobFormat: String {
    get {
      return graphQLMap["blobFormat"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "blobFormat")
    }
  }

  public var encryptionMethod: String {
    get {
      return graphQLMap["encryptionMethod"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "encryptionMethod")
    }
  }

  public var ownershipProofs: [String] {
    get {
      return graphQLMap["ownershipProofs"] as! [String]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ownershipProofs")
    }
  }
}

public struct UpdateVaultInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(token: String, id: GraphQLID, expectedVersion: Int, blob: String, blobFormat: String, encryptionMethod: String) {
    graphQLMap = ["token": token, "id": id, "expectedVersion": expectedVersion, "blob": blob, "blobFormat": blobFormat, "encryptionMethod": encryptionMethod]
  }

  public var token: String {
    get {
      return graphQLMap["token"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "token")
    }
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var expectedVersion: Int {
    get {
      return graphQLMap["expectedVersion"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "expectedVersion")
    }
  }

  public var blob: String {
    get {
      return graphQLMap["blob"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "blob")
    }
  }

  public var blobFormat: String {
    get {
      return graphQLMap["blobFormat"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "blobFormat")
    }
  }

  public var encryptionMethod: String {
    get {
      return graphQLMap["encryptionMethod"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "encryptionMethod")
    }
  }
}

public struct DeleteVaultInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public final class GetInitializationDataQuery: GraphQLQuery {
  public static let operationString =
    "query GetInitializationData {\n  getInitializationData {\n    __typename\n    owner\n    encryptionSalt\n    authenticationSalt\n    pbkdfRounds\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getInitializationData", type: .object(GetInitializationDatum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getInitializationData: GetInitializationDatum? = nil) {
      self.init(snapshot: ["__typename": "Query", "getInitializationData": getInitializationData.flatMap { $0.snapshot }])
    }

    public var getInitializationData: GetInitializationDatum? {
      get {
        return (snapshot["getInitializationData"] as? Snapshot).flatMap { GetInitializationDatum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getInitializationData")
      }
    }

    public struct GetInitializationDatum: GraphQLSelectionSet {
      public static let possibleTypes = ["InitializationData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("encryptionSalt", type: .nonNull(.scalar(String.self))),
        GraphQLField("authenticationSalt", type: .nonNull(.scalar(String.self))),
        GraphQLField("pbkdfRounds", type: .nonNull(.scalar(Int.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(owner: GraphQLID, encryptionSalt: String, authenticationSalt: String, pbkdfRounds: Int) {
        self.init(snapshot: ["__typename": "InitializationData", "owner": owner, "encryptionSalt": encryptionSalt, "authenticationSalt": authenticationSalt, "pbkdfRounds": pbkdfRounds])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var owner: GraphQLID {
        get {
          return snapshot["owner"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var encryptionSalt: String {
        get {
          return snapshot["encryptionSalt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "encryptionSalt")
        }
      }

      public var authenticationSalt: String {
        get {
          return snapshot["authenticationSalt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "authenticationSalt")
        }
      }

      public var pbkdfRounds: Int {
        get {
          return snapshot["pbkdfRounds"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "pbkdfRounds")
        }
      }
    }
  }
}

public final class GetVaultQuery: GraphQLQuery {
  public static let operationString =
    "query GetVault($token: String!, $id: ID!) {\n  getVault(token: $token, id: $id) {\n    __typename\n    id\n    version\n    createdAtEpochMs\n    updatedAtEpochMs\n    owner\n    blob\n    blobFormat\n    encryptionMethod\n    owners {\n      __typename\n      id\n      issuer\n    }\n  }\n}"

  public var token: String
  public var id: GraphQLID

  public init(token: String, id: GraphQLID) {
    self.token = token
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["token": token, "id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getVault", arguments: ["token": GraphQLVariable("token"), "id": GraphQLVariable("id")], type: .object(GetVault.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getVault: GetVault? = nil) {
      self.init(snapshot: ["__typename": "Query", "getVault": getVault.flatMap { $0.snapshot }])
    }

    public var getVault: GetVault? {
      get {
        return (snapshot["getVault"] as? Snapshot).flatMap { GetVault(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getVault")
      }
    }

    public struct GetVault: GraphQLSelectionSet {
      public static let possibleTypes = ["Vault"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("blob", type: .nonNull(.scalar(String.self))),
        GraphQLField("blobFormat", type: .nonNull(.scalar(String.self))),
        GraphQLField("encryptionMethod", type: .nonNull(.scalar(String.self))),
        GraphQLField("owners", type: .nonNull(.list(.nonNull(.object(Owner.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, owner: GraphQLID, blob: String, blobFormat: String, encryptionMethod: String, owners: [Owner]) {
        self.init(snapshot: ["__typename": "Vault", "id": id, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "owner": owner, "blob": blob, "blobFormat": blobFormat, "encryptionMethod": encryptionMethod, "owners": owners.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var owner: GraphQLID {
        get {
          return snapshot["owner"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var blob: String {
        get {
          return snapshot["blob"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "blob")
        }
      }

      public var blobFormat: String {
        get {
          return snapshot["blobFormat"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "blobFormat")
        }
      }

      public var encryptionMethod: String {
        get {
          return snapshot["encryptionMethod"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "encryptionMethod")
        }
      }

      public var owners: [Owner] {
        get {
          return (snapshot["owners"] as! [Snapshot]).map { Owner(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "owners")
        }
      }

      public struct Owner: GraphQLSelectionSet {
        public static let possibleTypes = ["Owner"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String, issuer: String) {
          self.init(snapshot: ["__typename": "Owner", "id": id, "issuer": issuer])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var issuer: String {
          get {
            return snapshot["issuer"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "issuer")
          }
        }
      }
    }
  }
}

public final class ListVaultsQuery: GraphQLQuery {
  public static let operationString =
    "query ListVaults($token: String!, $limit: Int, $nextToken: String) {\n  listVaults(token: $token, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n      owner\n      blob\n      blobFormat\n      encryptionMethod\n      owners {\n        __typename\n        id\n        issuer\n      }\n    }\n    nextToken\n  }\n}"

  public var token: String
  public var limit: Int?
  public var nextToken: String?

  public init(token: String, limit: Int? = nil, nextToken: String? = nil) {
    self.token = token
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["token": token, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listVaults", arguments: ["token": GraphQLVariable("token"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListVault.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listVaults: ListVault? = nil) {
      self.init(snapshot: ["__typename": "Query", "listVaults": listVaults.flatMap { $0.snapshot }])
    }

    public var listVaults: ListVault? {
      get {
        return (snapshot["listVaults"] as? Snapshot).flatMap { ListVault(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listVaults")
      }
    }

    public struct ListVault: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelVaultConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .list(.nonNull(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item]? = nil, nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelVaultConnection", "items": items.flatMap { $0.map { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item]? {
        get {
          return (snapshot["items"] as? [Snapshot]).flatMap { $0.map { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Vault"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("blob", type: .nonNull(.scalar(String.self))),
          GraphQLField("blobFormat", type: .nonNull(.scalar(String.self))),
          GraphQLField("encryptionMethod", type: .nonNull(.scalar(String.self))),
          GraphQLField("owners", type: .nonNull(.list(.nonNull(.object(Owner.selections))))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, owner: GraphQLID, blob: String, blobFormat: String, encryptionMethod: String, owners: [Owner]) {
          self.init(snapshot: ["__typename": "Vault", "id": id, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "owner": owner, "blob": blob, "blobFormat": blobFormat, "encryptionMethod": encryptionMethod, "owners": owners.map { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var blob: String {
          get {
            return snapshot["blob"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "blob")
          }
        }

        public var blobFormat: String {
          get {
            return snapshot["blobFormat"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "blobFormat")
          }
        }

        public var encryptionMethod: String {
          get {
            return snapshot["encryptionMethod"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "encryptionMethod")
          }
        }

        public var owners: [Owner] {
          get {
            return (snapshot["owners"] as! [Snapshot]).map { Owner(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "owners")
          }
        }

        public struct Owner: GraphQLSelectionSet {
          public static let possibleTypes = ["Owner"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(String.self))),
            GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(id: String, issuer: String) {
            self.init(snapshot: ["__typename": "Owner", "id": id, "issuer": issuer])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: String {
            get {
              return snapshot["id"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
            }
          }

          public var issuer: String {
            get {
              return snapshot["issuer"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "issuer")
            }
          }
        }
      }
    }
  }
}

public final class ListVaultsMetadataOnlyQuery: GraphQLQuery {
  public static let operationString =
    "query ListVaultsMetadataOnly($limit: Int, $nextToken: String) {\n  listVaultsMetadataOnly(limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n      owner\n      blobFormat\n      encryptionMethod\n      owners {\n        __typename\n        id\n        issuer\n      }\n    }\n    nextToken\n  }\n}"

  public var limit: Int?
  public var nextToken: String?

  public init(limit: Int? = nil, nextToken: String? = nil) {
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listVaultsMetadataOnly", arguments: ["limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListVaultsMetadataOnly.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listVaultsMetadataOnly: ListVaultsMetadataOnly? = nil) {
      self.init(snapshot: ["__typename": "Query", "listVaultsMetadataOnly": listVaultsMetadataOnly.flatMap { $0.snapshot }])
    }

    public var listVaultsMetadataOnly: ListVaultsMetadataOnly? {
      get {
        return (snapshot["listVaultsMetadataOnly"] as? Snapshot).flatMap { ListVaultsMetadataOnly(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listVaultsMetadataOnly")
      }
    }

    public struct ListVaultsMetadataOnly: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelVaultMetadataConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .list(.nonNull(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item]? = nil, nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelVaultMetadataConnection", "items": items.flatMap { $0.map { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item]? {
        get {
          return (snapshot["items"] as? [Snapshot]).flatMap { $0.map { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["VaultMetadata"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("blobFormat", type: .nonNull(.scalar(String.self))),
          GraphQLField("encryptionMethod", type: .nonNull(.scalar(String.self))),
          GraphQLField("owners", type: .nonNull(.list(.nonNull(.object(Owner.selections))))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, owner: GraphQLID, blobFormat: String, encryptionMethod: String, owners: [Owner]) {
          self.init(snapshot: ["__typename": "VaultMetadata", "id": id, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "owner": owner, "blobFormat": blobFormat, "encryptionMethod": encryptionMethod, "owners": owners.map { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var blobFormat: String {
          get {
            return snapshot["blobFormat"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "blobFormat")
          }
        }

        public var encryptionMethod: String {
          get {
            return snapshot["encryptionMethod"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "encryptionMethod")
          }
        }

        public var owners: [Owner] {
          get {
            return (snapshot["owners"] as! [Snapshot]).map { Owner(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "owners")
          }
        }

        public struct Owner: GraphQLSelectionSet {
          public static let possibleTypes = ["Owner"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(String.self))),
            GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(id: String, issuer: String) {
            self.init(snapshot: ["__typename": "Owner", "id": id, "issuer": issuer])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: String {
            get {
              return snapshot["id"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
            }
          }

          public var issuer: String {
            get {
              return snapshot["issuer"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "issuer")
            }
          }
        }
      }
    }
  }
}

public final class CreateVaultMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateVault($input: CreateVaultInput) {\n  createVault(input: $input) {\n    __typename\n    id\n    version\n    createdAtEpochMs\n    updatedAtEpochMs\n    owner\n    blobFormat\n    encryptionMethod\n    owners {\n      __typename\n      id\n      issuer\n    }\n  }\n}"

  public var input: CreateVaultInput?

  public init(input: CreateVaultInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createVault", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(CreateVault.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createVault: CreateVault) {
      self.init(snapshot: ["__typename": "Mutation", "createVault": createVault.snapshot])
    }

    public var createVault: CreateVault {
      get {
        return CreateVault(snapshot: snapshot["createVault"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "createVault")
      }
    }

    public struct CreateVault: GraphQLSelectionSet {
      public static let possibleTypes = ["VaultMetadata"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("blobFormat", type: .nonNull(.scalar(String.self))),
        GraphQLField("encryptionMethod", type: .nonNull(.scalar(String.self))),
        GraphQLField("owners", type: .nonNull(.list(.nonNull(.object(Owner.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, owner: GraphQLID, blobFormat: String, encryptionMethod: String, owners: [Owner]) {
        self.init(snapshot: ["__typename": "VaultMetadata", "id": id, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "owner": owner, "blobFormat": blobFormat, "encryptionMethod": encryptionMethod, "owners": owners.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var owner: GraphQLID {
        get {
          return snapshot["owner"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var blobFormat: String {
        get {
          return snapshot["blobFormat"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "blobFormat")
        }
      }

      public var encryptionMethod: String {
        get {
          return snapshot["encryptionMethod"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "encryptionMethod")
        }
      }

      public var owners: [Owner] {
        get {
          return (snapshot["owners"] as! [Snapshot]).map { Owner(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "owners")
        }
      }

      public struct Owner: GraphQLSelectionSet {
        public static let possibleTypes = ["Owner"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String, issuer: String) {
          self.init(snapshot: ["__typename": "Owner", "id": id, "issuer": issuer])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var issuer: String {
          get {
            return snapshot["issuer"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "issuer")
          }
        }
      }
    }
  }
}

public final class UpdateVaultMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateVault($input: UpdateVaultInput) {\n  updateVault(input: $input) {\n    __typename\n    id\n    version\n    createdAtEpochMs\n    updatedAtEpochMs\n    owner\n    blobFormat\n    encryptionMethod\n    owners {\n      __typename\n      id\n      issuer\n    }\n  }\n}"

  public var input: UpdateVaultInput?

  public init(input: UpdateVaultInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateVault", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(UpdateVault.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateVault: UpdateVault) {
      self.init(snapshot: ["__typename": "Mutation", "updateVault": updateVault.snapshot])
    }

    public var updateVault: UpdateVault {
      get {
        return UpdateVault(snapshot: snapshot["updateVault"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "updateVault")
      }
    }

    public struct UpdateVault: GraphQLSelectionSet {
      public static let possibleTypes = ["VaultMetadata"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("blobFormat", type: .nonNull(.scalar(String.self))),
        GraphQLField("encryptionMethod", type: .nonNull(.scalar(String.self))),
        GraphQLField("owners", type: .nonNull(.list(.nonNull(.object(Owner.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, owner: GraphQLID, blobFormat: String, encryptionMethod: String, owners: [Owner]) {
        self.init(snapshot: ["__typename": "VaultMetadata", "id": id, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "owner": owner, "blobFormat": blobFormat, "encryptionMethod": encryptionMethod, "owners": owners.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var owner: GraphQLID {
        get {
          return snapshot["owner"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var blobFormat: String {
        get {
          return snapshot["blobFormat"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "blobFormat")
        }
      }

      public var encryptionMethod: String {
        get {
          return snapshot["encryptionMethod"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "encryptionMethod")
        }
      }

      public var owners: [Owner] {
        get {
          return (snapshot["owners"] as! [Snapshot]).map { Owner(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "owners")
        }
      }

      public struct Owner: GraphQLSelectionSet {
        public static let possibleTypes = ["Owner"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String, issuer: String) {
          self.init(snapshot: ["__typename": "Owner", "id": id, "issuer": issuer])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var issuer: String {
          get {
            return snapshot["issuer"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "issuer")
          }
        }
      }
    }
  }
}

public final class DeleteVaultMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteVault($input: DeleteVaultInput) {\n  deleteVault(input: $input) {\n    __typename\n    id\n    version\n    createdAtEpochMs\n    updatedAtEpochMs\n    owner\n    blobFormat\n    encryptionMethod\n    owners {\n      __typename\n      id\n      issuer\n    }\n  }\n}"

  public var input: DeleteVaultInput?

  public init(input: DeleteVaultInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteVault", arguments: ["input": GraphQLVariable("input")], type: .object(DeleteVault.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteVault: DeleteVault? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteVault": deleteVault.flatMap { $0.snapshot }])
    }

    public var deleteVault: DeleteVault? {
      get {
        return (snapshot["deleteVault"] as? Snapshot).flatMap { DeleteVault(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteVault")
      }
    }

    public struct DeleteVault: GraphQLSelectionSet {
      public static let possibleTypes = ["VaultMetadata"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("blobFormat", type: .nonNull(.scalar(String.self))),
        GraphQLField("encryptionMethod", type: .nonNull(.scalar(String.self))),
        GraphQLField("owners", type: .nonNull(.list(.nonNull(.object(Owner.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, owner: GraphQLID, blobFormat: String, encryptionMethod: String, owners: [Owner]) {
        self.init(snapshot: ["__typename": "VaultMetadata", "id": id, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "owner": owner, "blobFormat": blobFormat, "encryptionMethod": encryptionMethod, "owners": owners.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var owner: GraphQLID {
        get {
          return snapshot["owner"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var blobFormat: String {
        get {
          return snapshot["blobFormat"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "blobFormat")
        }
      }

      public var encryptionMethod: String {
        get {
          return snapshot["encryptionMethod"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "encryptionMethod")
        }
      }

      public var owners: [Owner] {
        get {
          return (snapshot["owners"] as! [Snapshot]).map { Owner(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "owners")
        }
      }

      public struct Owner: GraphQLSelectionSet {
        public static let possibleTypes = ["Owner"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String, issuer: String) {
          self.init(snapshot: ["__typename": "Owner", "id": id, "issuer": issuer])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var issuer: String {
          get {
            return snapshot["issuer"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "issuer")
          }
        }
      }
    }
  }
}

public final class DeregisterMutation: GraphQLMutation {
  public static let operationString =
    "mutation Deregister {\n  deregister {\n    __typename\n    username\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deregister", type: .nonNull(.object(Deregister.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deregister: Deregister) {
      self.init(snapshot: ["__typename": "Mutation", "deregister": deregister.snapshot])
    }

    public var deregister: Deregister {
      get {
        return Deregister(snapshot: snapshot["deregister"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "deregister")
      }
    }

    public struct Deregister: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(username: String) {
        self.init(snapshot: ["__typename": "User", "username": username])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }
    }
  }
}
