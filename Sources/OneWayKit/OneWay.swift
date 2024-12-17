//
//  OneWay.swift
//
//
//  Created by Fomagran on 10/12/24.
//

import Foundation
import Combine

public final class OneWay<Feature: ViewFeature>: GlobalHandlable {
    
    private let queue = DispatchQueue(label: "onewaykit.\(Feature.self)", qos: .userInitiated)
    internal var subscriptions: [String: AnyCancellable] = [:]
    
    internal let subject: CurrentValueSubject<Feature.State, Never>
    public let action = CurrentValueSubject<Feature.Action?, Never>(nil)
    
    private var newState: Feature.State?
    
    public let tracer = Tracer()
    private let context: AnyClass?
    
    public init(initialState: Feature.State, context: AnyClass? = nil) {
        self.subject = CurrentValueSubject<Feature.State, Never>(initialState)
        self.context = context
        self.observeSubject()
    }
    
    public var state: Feature.State {
        subject.value
    }
    
    public var statePublisher: AnyPublisher<Feature.State, Never> {
        subject.eraseToAnyPublisher()
    }
    
}


// MARK: - Helpers

extension OneWay {
    
    public func send(_ action: Feature.Action) {
        queue.sync { [weak self] in
            guard let self else { return }
            self.action.value = action
            self.update(subject.value, action)
        }
    }
    
    private func update(_ currentState: Feature.State, _ action: Feature.Action) {
        newState = if let newState {
            Feature.updater(newState, action)
        } else {
            Feature.updater(currentState, action)
        }
        
        Feature.middlewares?.forEach { middleware in
            middleware.send(action, currentState: currentState)
                .receive(on: RunLoop.main)
                .handleEvents(receiveCompletion: { [weak self] _ in
                    guard let self else { return }
                    self.subscriptions.removeValue(forKey: "\(middleware) \(action)") }
                )
                .sink { [weak self] in
                    if let action = $0 as? Feature.Action {
                        self?.send(action)
                    } else if
                        let action = $0 as? any CancelAction,
                        let actionToCancel = action.actionToCancel {
                        self?.cancel(actionToCancel, key: "\(middleware) \(actionToCancel)")
                    }
                }
                .store(in: &subscriptions, key: "\(middleware) \(action)")
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self, let newState = self.newState else { return }
            
            tracer.trace(
                shouldLog: state.shouldLog,
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
    
    func store(in dictionary: inout [String: AnyCancellable], key: String? = nil) {
        if let key {
            dictionary[key] = self
        } else {
            dictionary[UUID().uuidString] = self
        }
    }
    
}
