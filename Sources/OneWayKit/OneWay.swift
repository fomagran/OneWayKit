//
//  OneWay.swift
//
//
//  Created by Fomagran on 10/12/24.
//

import Foundation
import Combine

/// A generic state management system designed for unidirectional data flow,
/// intended to work seamlessly with SwiftUI and provide robust state handling.
///
/// `OneWay` manages state (`Feature.State`) and actions (`Feature.Action`) in a thread-safe
/// manner, enabling middleware and tracing support. It conforms to `ObservableObject` for
/// SwiftUI integration.
///
/// - Note: This is a customizable, reusable framework component that follows
///         the principles of unidirectional data flow.

public final class OneWay<Feature: ViewFeature>: GlobalHandlable {
    
    /// A private queue to handle all state updates serially.
    private let queue = DispatchQueue(label: "onewaykit.\(Feature.self)", qos: .userInitiated)
    
    /// A dictionary to store subscriptions for Combine publishers.
    internal var subscriptions: [String: AnyCancellable] = [:]
    
    /// The core subject managing the current state.
    internal let subject: CurrentValueSubject<Feature.State, Never>
    
    /// A subject to handle the current action being processed.
    public let action = CurrentValueSubject<Feature.Action?, Never>(nil)
    
    /// A temporary holder for the next computed state before applying it.
    private var newState: Feature.State?
    
    /// A list of middlewares handling side effects for actions.
    private let middlewares: [Middleware]
    
    /// A tracer to log state transitions and actions, aiding in debugging and analytics.
    public let tracer = Tracer()
    
    /// Contextual information for tracing, typically the calling class.
    private let context: AnyClass?

    /// Initializes a `OneWay` instance with an initial state and optional context.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the feature.
    ///   - context: An optional context, such as the calling class, for tracing.
    ///   - middlewares:A list of middlewares handling side effects for actions.
    public init(initialState: Feature.State,
                context: AnyClass? = nil,
                middlewares: [Middleware] = []) {
        self.subject = CurrentValueSubject<Feature.State, Never>(initialState)
        self.context = context
        self.middlewares = middlewares
        self.observeSubject()
    }
    
    /// The current state of the feature.
    public var state: Feature.State {
        subject.value
    }
    
    /// A publisher that emits the current state whenever it changes.
    public var statePublisher: AnyPublisher<Feature.State, Never> {
        subject.eraseToAnyPublisher()
    }
}

// MARK: - Helpers

extension OneWay {
    
    /// Sends an action to the `OneWay` system, initiating a state update and optional tracing.
    ///
    /// - Parameters:
    ///   - action: The action to process.
    ///   - shouldTrace: Whether to enable tracing for this action. Defaults to `false`.
    public func send(_ action: Feature.Action, shouldTrace: Bool = false) {
        queue.sync { [weak self] in
            guard let self else { return }
            self.action.value = action
            self.update(subject.value, action, shouldTrace)
        }
    }
    
    /// Handles state updates and middleware execution for a given action.
    ///
    /// - Parameters:
    ///   - currentState: The current state before applying the action.
    ///   - action: The action to process.
    ///   - shouldTrace: Whether to enable tracing for this action.
    private func update(_ currentState: Feature.State, _ action: Feature.Action, _ shouldTrace: Bool) {
        // Compute the new state using the feature's updater.
        newState = if let newState {
            Feature.updater(newState, action)
        } else {
            Feature.updater(currentState, action)
        }
        
        // Process middlewares, if any, for additional side effects.
        middlewares.forEach { middleware in
            middleware.send(action, currentState: currentState)
                .receive(on: RunLoop.main)
                .handleEvents(receiveCompletion: { [weak self] _ in
                    guard let self else { return }

                    if subscriptions.keys.contains("\(middleware) \(action)") {
                        self.subscriptions.removeValue(forKey: "\(middleware) \(action)")
                    }
                })
                .sink { [weak self] in
                    if let action = $0 as? Feature.Action {
                        self?.send(action, shouldTrace: shouldTrace)
                    } else if
                        let action = $0 as? any CancelAction,
                        let actionToCancel = action.actionToCancel {
                        self?.cancel(actionToCancel, key: "\(middleware) \(actionToCancel)")
                    }
                }
                .store(in: &subscriptions, key: "\(middleware) \(action)")
        }
        
        // Apply the new state and perform tracing on the main queue.
        DispatchQueue.main.async { [weak self] in
            guard let self, let newState = self.newState else { return }
            
            tracer.trace(
                shouldTrace: shouldTrace,
                context: context,
                action: action,
                old: state,
                new: newState
            )
            
            self.subject.value = newState
            self.newState = nil
        }
    }
}

// MARK: - For SwiftUI

extension OneWay: ObservableObject {
    
    /// Observes changes to the state subject and notifies SwiftUI when updates occur.
    private func observeSubject() {
        subject
            .sink(receiveValue: { [weak self] newState in
                self?.objectWillChange.send()
            })
            .store(in: &subscriptions)
    }
}

// MARK: - Subscription

extension AnyCancellable {
    
    /// Stores a subscription in a dictionary with an optional key.
    ///
    /// - Parameters:
    ///   - dictionary: The dictionary to store the subscription.
    ///   - key: An optional key to identify the subscription. If not provided, a UUID is used.
    func store(in dictionary: inout [String: AnyCancellable], key: String? = nil) {
        dictionary[key ?? UUID().uuidString] = self
    }
}
