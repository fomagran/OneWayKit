//
//  OneWay+Cancel.swift
//  
//
//  Created by Fomagran on 10/12/24.
//

import Foundation

extension ViewAction {
    public static func cancel(for action: ViewAction) -> any CancelAction {
        return FeatureCancelAction(actionToCancel: action)
    }
}

public struct FeatureCancelAction: CancelAction {
    
    public typealias CancellableAction = ViewAction
    
    public var actionToCancel: (any CancellableAction)?
}

public protocol CancelAction: ViewAction {
    var actionToCancel: ViewAction? { get }
}

extension OneWay {
    public func cancel(_ action: ViewAction) {
        subscriptions[key(action)]?.cancel()
    }
}
