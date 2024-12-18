//
//  GlobalOneWay.swift
//  
//
//  Created by 안영훈 on 11/23/24.
//
import Foundation
import Combine

/// A protocol that defines the basic requirements for handling global state and actions.
///
/// Conforming types must provide a `State` and an `Action` type and implement
/// state management and action dispatch methods.
protocol GlobalHandlable {
    /// The state type associated with the feature.
    associatedtype State: ViewState
    
    /// The action type associated with the feature.
    associatedtype Action: ViewAction
    
    /// The current state of the feature.
    var state: State { get }
    
    /// A subject that emits the current state whenever it changes.
    var subject: CurrentValueSubject<State, Never> { get }
    
    /// Sends an action to update the state and optionally enables tracing.
    ///
    /// - Parameters:
    ///   - action: The action to process.
    ///   - shouldTrace: A flag indicating whether to trace this action.
    func send(_ action: Action, shouldTrace: Bool)
}

/// A global manager for registering, accessing, and interacting with `OneWay` instances.
///
/// `GlobalOneWay` provides centralized control over global state and actions, enabling
/// features to register their initial state, dispatch actions, and observe state changes
/// across the app. It uses a dictionary to store and manage `OneWay` instances by feature type.
public final class GlobalOneWay: NSObject {

    /// A dictionary to hold all registered `OneWay` instances by their feature type.
    private static var globalOneWays: [String: any GlobalHandlable] = [:]
    
    /// Retrieves a state publisher for a specific feature type.
    ///
    /// - Parameter feature: The feature type whose state publisher is required.
    /// - Returns: An `AnyPublisher` that emits state changes for the specified feature.
    ///            Returns an empty publisher if the feature has not been registered.
    public static func statePublisher<Feature: ViewFeature>(feature: Feature.Type) -> AnyPublisher<Feature.State, Never> {
        guard let oneWay = globalOneWays[String(describing: Feature.self)] as? OneWay<Feature> else {
            print("The initial state for the GlobalType \(feature) has not been registered.")
            return Empty().eraseToAnyPublisher()
        }
        
        return oneWay.subject.eraseToAnyPublisher()
    }
    
    /// Retrieves the `CurrentValueSubject` representing the current state of a specific feature.
    ///
    /// - Parameter feature: The feature type whose state is required.
    /// - Returns: A `CurrentValueSubject` for the feature's state, or `nil` if not registered.
    public static func state<Feature: ViewFeature>(feature: Feature.Type) -> CurrentValueSubject<Feature.State, Never>? {
        guard let oneWay = globalOneWays[String(describing: Feature.self)] as? OneWay<Feature> else {
            print("The initial state for the GlobalType \(feature) has not been registered.")
            return nil
        }
        
        return oneWay.subject
    }
    
    /// Dispatches an action to the `OneWay` instance associated with the given feature type.
    ///
    /// - Parameters:
    ///   - feature: The feature type whose `OneWay` instance will process the action.
    ///   - action: The action to dispatch.
    public static func send<Feature: ViewFeature>(feature: Feature.Type, _ action: Feature.Action) {
        guard let oneWay = globalOneWays[String(describing: Feature.self)] as? OneWay<Feature> else {
            return
        }
        
        oneWay.send(action)
    }
    
    /// Registers the initial state of a specific feature type and creates a corresponding `OneWay` instance.
    ///
    /// - Parameters:
    ///   - feature: The feature type to register.
    ///   - initialState: The initial state of the feature.
    public static func registerState<Feature: ViewFeature>(feature: Feature.Type, initialState: Feature.State) {
        guard globalOneWays[String(describing: Feature.self)] == nil else {
            return
        }
        
        globalOneWays[String(describing: Feature.self)] = OneWay<Feature>(initialState: initialState)
    }
}
