//
//  OneWayLogger.swift
//
//
//  Created by 안영훈 on 12/16/24.
//

import Foundation

public final class Tracer: NSObject {
    
    @Published public var event: String?
    
    public func trace(
        shouldLog: Bool,
        context: AnyClass? = nil,
        action: ViewAction,
        old: any ViewState,
        new: any ViewState
    ) {
        guard shouldLog else { return }
        
        
        let contextName: String = if let context {
            String(describing: context.self)
        } else {
            "Unknown"
        }
        
        let event = """
        [Context: \(contextName)]
        Action Triggered: \(action)
        Changed State:
        \(compareStructs(old, new))
        """
        
        self.event = event
    }
    
    private func compareStructs(_ old: any ViewState, _ new: any ViewState) -> String {
        var differences: String = ""
        
        let oldMirror = Mirror(reflecting: old)
        let newMirror = Mirror(reflecting: new)
        
        for (oldChild, newChild) in zip(oldMirror.children, newMirror.children) {
            guard let propertyName = oldChild.label else { continue }
            
            if isDifferent(oldChild.value, newChild.value) {
                if !differences.isEmpty {
                    differences += "\n"
                }
                differences += "\(propertyName): \(oldChild.value) -> \(newChild.value)"
            }
        }
        
        return differences.isEmpty ? "There are no changes." : differences
    }
    
    private func isDifferent(_ lhs: Any, _ rhs: Any) -> Bool {
        return "\(lhs)" != "\(rhs)"
    }
    
}
