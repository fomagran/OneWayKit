//
//  OneWay+Feature.swift
//  
//
//  Created by Fomagran on 10/12/24.
//

import Combine

/// A protocol that represents a state in a unidirectional data flow architecture.
///
/// Conforming types must be `Equatable` to enable efficient state comparison.
public protocol ViewState: Equatable {}

/// A protocol that represents an action in a unidirectional data flow architecture.
///
/// Actions describe the user or system events that trigger state updates.
///
/// - Note: Includes a method to create a cancellation action.
public protocol ViewAction {
    /// Creates a cancellation action for a given action.
    ///
    /// - Parameter action: The action to cancel.
    /// - Returns: A `CancelAction` instance for the specified action.
    static func cancel(for action: ViewAction) -> CancelAction
}

/// A protocol representing a middleware component in a unidirectional data flow architecture.
///
/// Middleware intercepts actions and performs side effects, such as logging or network requests,
/// and can optionally dispatch new actions.
///
/// - Note: Middleware enables additional processing outside the direct state update logic.
public protocol Middleware {
    /// Processes an action and returns a publisher that emits new actions.
    ///
    /// - Parameters:
    ///   - action: The action to process.
    ///   - currentState: The current state of the system.
    /// - Returns: A publisher that emits new actions to be handled by the system.
    func send(_ action: ViewAction, currentState: any ViewState) -> AnyPublisher<ViewAction, Never>
}

/// A protocol that defines the requirements for a feature in a unidirectional data flow architecture.
///
/// Features define the state and actions for a specific domain or component of the app,
/// as well as the logic for updating the state based on actions and optional middleware.
///
/// - Note: This protocol encapsulates the core logic and data flow for a feature.
public protocol ViewFeature {
    /// The type of state managed by the feature.
    associatedtype State: ViewState
    
    /// The type of actions that the feature can handle.
    associatedtype Action: ViewAction
    
    /// A typealias for the state update function.
    typealias Updater = (State, Action) -> State
    
    /// The state update logic for the feature.
    ///
    /// This function takes the current state and an action, and returns the new state.
    static var updater: Updater { get }
    
    /// An optional array of middleware to process actions and perform side effects.
    ///
    /// Middleware can be used for tasks such as logging, analytics, or asynchronous operations.
    static var middlewares: [any Middleware]? { get }
}
