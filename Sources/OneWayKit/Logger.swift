//
//  OneWayLogger.swift
//
//
//  Created by 안영훈 on 12/16/24.
//

import Foundation

public final class Logger: NSObject {
    
    public static let shared = Logger()
    
    public func log(
        shouldLog: Bool,
        contextName: String? = nil,
        action: FeatureAction,
        old: any FeatureState,
        new: any FeatureState
    ) {
        guard shouldLog else { return }
        
        print("""
        -----------------------------
        [Context: \(contextName ?? "Unknown")]
        Action Triggered: \(action)
        Changed State:
        \(compareStructs(old, new))
        -----------------------------
        """)
        
    }
    
    private func compareStructs(_ old: any FeatureState, _ new: any FeatureState) -> String {
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
