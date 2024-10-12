//
//  OneWay+Cancel.swift
//  
//
//  Created by Fomagran on 10/12/24.
//

import Foundation

extension FeatureAction {
    public static func cancel(for action: FeatureAction) -> any CancelAction {
        return FeatureCancelAction(actionToCancel: action)
    }
}

public struct FeatureCancelAction: CancelAction {
    
    public typealias CancellableAction = FeatureAction
    
    public var actionToCancel: (any CancellableAction)?
}

public protocol CancelAction: FeatureAction {
    var actionToCancel: FeatureAction? { get }
}

extension OneWay {
    public func cancel(_ action: FeatureAction) {
        subscriptions[key(action)]?.cancel()
    }
}
