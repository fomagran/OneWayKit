//
//  OneWay+Cancel.swift
//  
//
//  Created by Fomagran on 10/12/24.
//

import Foundation

/// Extends `ViewAction` to provide a convenience method for creating a cancellation action.
///
/// - Note: This method is used to generate a `CancelAction` for a specific action.
extension ViewAction {
    /// Creates a cancellation action for the given action.
    ///
    /// - Parameter action: The action to cancel.
    /// - Returns: A `CancelAction` instance that wraps the action to cancel.
    public static func cancel(for action: ViewAction) -> any CancelAction {
        return FeatureCancelAction(actionToCancel: action)
    }
}

/// A concrete implementation of `CancelAction` for handling action cancellations.
///
/// `FeatureCancelAction` is used to wrap a `ViewAction` that should be cancelled.
public struct FeatureCancelAction: CancelAction {
    
    /// The type of action that can be cancelled.
    public typealias CancellableAction = ViewAction
    
    /// The action to cancel.
    public var actionToCancel: (any CancellableAction)?
}

/// A protocol representing an action that can cancel another action.
///
/// Conforming types should specify the action to be cancelled through `actionToCancel`.
public protocol CancelAction: ViewAction {
    /// The action that should be cancelled.
    var actionToCancel: ViewAction? { get }
}

/// Extends `OneWay` to handle cancellation of actions and their associated subscriptions.
extension OneWay {
    /// Cancels a subscription associated with a specific action.
    ///
    /// - Parameters:
    ///   - action: The action to cancel.
    ///   - key: The unique key associated with the subscription.
    public func cancel(_ action: ViewAction, key: String) {
        subscriptions[key]?.cancel()
    }
}
