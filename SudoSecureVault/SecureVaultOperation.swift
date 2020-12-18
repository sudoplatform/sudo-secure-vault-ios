//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoLogging
import AWSAppSync

/// List of possible errors returned by `SecureVaultOperation` and its subclasses.
///
/// - preconditionFailure: One of preconditions of the operation was not met.
public enum SecureVaultOperationError: Error, Hashable {
    case preconditionFailure
}

public enum SecureVaultOperationState: Int {
    case ready = 0
    case executing
    case finished
}

/// Custom base operation for vault  lifecycle operations. Provides common functionality
/// that all subclasses are expected to provide.
open class SecureVaultOperation: Operation {

    struct SecureVaultServiceError {
        static let type = "errorType"
        static let serviceError = "sudoplatform.ServiceError"
        static let insufficientEntitlementsError = "sudoplatform.InsufficientEntitlementsError"
        static let conditionalCheckFailedException = "DynamoDB:ConditionalCheckFailedException"
        static let invalidOwnershipProofError = "sudoplatform.vault.InvalidOwnershipProofError"
        static let notAuthorizedError = "sudoplatform.vault.NotAuthorizedError"
        static let tokenValidationError = "sudoplatform.vault.TokenValidationError"
    }

    private struct Constants {
        static let IsExecuting = "isExecuting"
        static let IsFinished = "isFinished"
        static let IsCancelled = "isCancelled"
    }

    let queue = DispatchQueue(label: "com.sudoplatform.vault.client.operation")

    let logger: Logger

    private let stateLock = NSLock()

    private var _state: SecureVaultOperationState = .ready

    /// Operation state.
    public private(set) var state: SecureVaultOperationState {
        get {
            return self.stateLock.withCriticalScope { self._state }
        }
        set {
            self.stateLock.withCriticalScope {
                if self._state != newValue {
                    self._state = newValue
                }
            }
        }
    }

    /// Operation ID.
    public var id: String = UUID().uuidString

    /// Time at which the operation was queued.
    public var queuedTime = Date(timeIntervalSince1970: 0)

    /// Operation start time.
    public private(set) var startTime = Date(timeIntervalSince1970: 0)

    /// Operation finish time.
    public private(set) var finishTime = Date(timeIntervalSince1970: 0)

    /// Input parameters
    public var input: [String: Any] = [:]

    /// Output parameters.
    public var output: [String: Any] = [:]

    /// Operation error.
    open var error: Error?

    // Indicates whether or not to copy the output from dependencies as
    // input to this operation.
    public var copyDependenciesOutputAsInput: Bool = false

    override open var isReady: Bool {
        return self.state == .ready
    }

    override open var isExecuting: Bool {
        return self.state == .executing
    }

    private var _cancelled = false

    override open var isCancelled: Bool {
        return self.stateLock.withCriticalScope { _cancelled }
    }

    override open var isFinished: Bool {
        return self.state == .finished
    }

    override open var isAsynchronous: Bool {
        return false
    }

    public init(logger: Logger) {
        self.logger = logger
    }

    /// Marks the operation as completed. Subclasses are expected to
    /// call this method whether the operation has completed successfully
    /// or unsuccessfully.
    open func done() {
        guard !self.isFinished else {
            return
        }

        self.finishTime = Date()
        let isExecuting = self.isExecuting

        if isExecuting {
            self.willChangeValue(forKey: Constants.IsExecuting)
        }

        self.willChangeValue(forKey: Constants.IsFinished)
        self.state = .finished
        self.didChangeValue(forKey: Constants.IsFinished)

        if isExecuting {
            self.didChangeValue(forKey: Constants.IsExecuting)
        }

        let elapsed = self.finishTime.timeIntervalSince(self.startTime)
        let queueTime = (self.queuedTime == Date(timeIntervalSince1970: 0) ? 0.0 : self.finishTime.timeIntervalSince(self.queuedTime))
        self.logger.info("\(type(of: self)) (id=\(self.id)) finished in \(elapsed) sec (queueTime: \(queueTime) sec. error: \(String(describing: self.error))")
    }

    /// Evaluates preconditions to determined whether or not the operation should
    /// be started.
    ///
    /// - Returns: `true` if all preconditions have been met.
    open func evaluatePreconditions() -> Bool {
        if !self.dependencies.isEmpty {
            for operation in self.dependencies {
                guard let operation = operation as? SecureVaultOperation, operation.error == nil else {
                    return false
                }
            }
        }

        return true
    }

    /// Executes the operation. Subclasses must override this method.
    open func execute() {
        fatalError("Must override!")
    }

    override open func start() {
        guard !_cancelled else {
            return self.done()
        }

        if self.state == .ready {
            self.startTime = Date()

            if self.copyDependenciesOutputAsInput {
                // Copy the dependencies' output as input.
                for dependency in self.dependencies {
                    guard let vaultOp = dependency as? SecureVaultOperation else {
                        break
                    }

                    self.input.merge(vaultOp.output) {(_, new) in new}
                }
            }

            guard self.evaluatePreconditions() else {
                self.error = SecureVaultOperationError.preconditionFailure
                self.done()
                return
            }

            self.willChangeValue(forKey: Constants.IsExecuting)
            self.state = .executing
            self.didChangeValue(forKey: Constants.IsExecuting)

            self.logger.info("\(type(of: self)) started.")
            self.execute()
        }
    }

    override open func cancel() {
        // By default you cannot cancel an operation that has already begun executing
        // since it requires more care to unwind a job, e.g rollback changes, clean up
        // associated system resources. It's expected for the subclasses to override
        // cancel if they can support a proper cancel during execution. In addition,
        // it makes no sense to cancel already finished operation so in reality we
        // are only allowing ready operation to be cancelled.
        guard self.isReady else {
            return
        }

        self.willChangeValue(forKey: Constants.IsCancelled)
        self.stateLock.withCriticalScope { _cancelled = true }
        self.didChangeValue(forKey: Constants.IsCancelled)
    }

    open func graphQLErrorToClientError(error: GraphQLError) -> SudoSecureVaultClientError {
        let message = "\(type(of: self)) received GraphQL error: \(error)"
        self.logger.error(message)

        if let errorType = error[SecureVaultOperation.SecureVaultServiceError.type] as? String {
            switch errorType {
            case SecureVaultOperation.SecureVaultServiceError.tokenValidationError:
                return SudoSecureVaultClientError.notAuthorized
            case SecureVaultOperation.SecureVaultServiceError.notAuthorizedError:
                return SudoSecureVaultClientError.notAuthorized
            case SecureVaultOperation.SecureVaultServiceError.invalidOwnershipProofError:
                return SudoSecureVaultClientError.invalidOwnershipProofError
            case SecureVaultOperation.SecureVaultServiceError.insufficientEntitlementsError:
                return SudoSecureVaultClientError.insufficientEntitlements
            case SecureVaultOperation.SecureVaultServiceError.conditionalCheckFailedException:
                return SudoSecureVaultClientError.versionMismatch
            case SecureVaultOperation.SecureVaultServiceError.serviceError:
                return SudoSecureVaultClientError.serviceError
            default:
                return SudoSecureVaultClientError.graphQLError(description: message)
            }
        } else {
            return SudoSecureVaultClientError.graphQLError(description: message)
        }
    }

}
