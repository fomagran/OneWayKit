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
        contextName: String? = nil,
        action: ViewAction,
        old: any ViewState,
        new: any ViewState
    ) {
        guard shouldLog else { return }
        
        let event = """
        -----------------------------
        [Context: \(contextName ?? "Unknown")]
        Action Triggered: \(action)
        Changed State:
        \(compareStructs(old, new))
        -----------------------------
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
        
        return differences.isEmpty ? "아무것도 변하지 않았습니다." : differences
    }
    
    private func isDifferent(_ lhs: Any, _ rhs: Any) -> Bool {
        return "\(lhs)" != "\(rhs)"
    }
    
}
