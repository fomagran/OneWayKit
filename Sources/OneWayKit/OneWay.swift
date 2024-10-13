//
//  OneWay.swift
//
//
//  Created by Fomagran on 10/12/24.
//

import Combine
import Foundation

public protocol OneWayHandlable {
    associatedtype State: FeatureState
    associatedtype Action: FeatureAction
    
    var subject: CurrentValueSubject<State, Never> { get }
    var state: State { get }
    
    func send(_ action: Action)
    func cancel(_ action: FeatureAction)
    func transform<Action>(id: String, action: CurrentValueSubject<Action?, Never>, transfer: @escaping (Action) -> Void)
}

public final class OneWay<Feature: Featurable>: ObservableObject {
    
    private let queue = DispatchQueue(label: "onewaykit.\(Feature.id)", qos: .userInitiated)
    internal var subscriptions: [String: AnyCancellable] = [:]
    
    public let subject: CurrentValueSubject<Feature.State, Never>
    public let action = CurrentValueSubject<Feature.Action?, Never>(nil)
    
    public init(initialState: Feature.State) {
        self.subject = CurrentValueSubject<Feature.State, Never>(initialState)
    }
    
    public var state: Feature.State {
        subject.value
    }
    
    public var statePublisher: AnyPublisher<Feature.State, Never> {
        subject.eraseToAnyPublisher()
    }
}


// MARK: - OneWayHandlable

extension OneWay: OneWayHandlable {
    
    public func send(_ action: Feature.Action) {
        queue.sync { [weak self] in
            guard let self else{ return }
            
            self.action.value = action
            self.update(subject.value, action)
        }
    }
    
    private func update(_ currentState: Feature.State, _ action: Feature.Action) {
        let newState = Feature.updater(currentState, action)
        
        Feature.asyncActions?.forEach { asyncAction in
            asyncAction.send(action, currentState: currentState)
                .receive(on: RunLoop.main)
                .handleEvents(receiveCompletion: { [weak self] _ in
                    guard let self else { return }
                    self.subscriptions.removeValue(forKey: self.key(action)) }
                )
                .sink { [weak self] in
                    if let action = $0 as? Feature.Action {
                        self?.send(action)
                    } else if
                        let action = $0 as? any CancelAction,
                        let actionToCancel = action.actionToCancel {
                        self?.cancel(actionToCancel)
                    }
                    
                }
                .store(in: &subscriptions, key: key(action))
        }
        
        Task { @MainActor [weak self] in
            self?.subject.value = newState
        }
    }
    
    public func transform<ChildAction>(id: String, action: CurrentValueSubject<ChildAction?, Never>, transfer: @escaping (ChildAction) -> Void) {

        action.sink { action in
            guard let action else { return }
            transfer(action)
        }
        .store(in: &subscriptions, key: id)
    }
    
}
