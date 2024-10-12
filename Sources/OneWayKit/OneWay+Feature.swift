//
//  OneWay+Feature.swift
//  
//
//  Created by Fomagran on 10/12/24.
//

import Combine

public protocol FeatureState {}

public protocol FeatureAction {
    static func cancel(for action: FeatureAction) -> CancelAction
}

public protocol AsyncAction {
    func send(_ action: FeatureAction, currentState: FeatureState) -> AnyPublisher<FeatureAction, Never>
}

public protocol Featurable {
    static var id: String { get }
    
    associatedtype State: FeatureState
    associatedtype Action: FeatureAction
    typealias Updater = (State, Action) -> State
    
    static var updater: Updater { get }
    static var asyncActions: [any AsyncAction]? { get }
}
