//
//  OneWay+Feature.swift
//  
//
//  Created by Fomagran on 10/12/24.
//

import Combine

public protocol ViewState: Equatable {
    var shouldLog: Bool { get }
}

public protocol ViewAction {
    static func cancel(for action: ViewAction) -> CancelAction
}

public protocol Middleware {
    func send(_ action: ViewAction, currentState: any ViewState) -> AnyPublisher<ViewAction, Never>
}

public protocol ViewFeature {
    static var id: String { get }
    
    associatedtype State: ViewState
    associatedtype Action: ViewAction
    typealias Updater = (State, Action) -> State
    
    static var updater: Updater { get }
    static var middlewares: [any Middleware]? { get }
}
