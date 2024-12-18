//
//  OneWayLogger.swift
//
//
//  Created by 안영훈 on 12/16/24.
//

import Foundation

/// A utility class for tracing state changes and actions in a unidirectional data flow architecture.
///
/// `Tracer` is designed to help debug and monitor state changes triggered by actions.
/// It logs detailed information, including the context, action, and differences between
/// the old and new states.
public final class Tracer: NSObject {
    
    /// A published property that emits the most recent tracing event.
    @Published public var event: String?
    
    /// Traces an action and the resulting state change, producing a formatted event string.
    ///
    /// - Parameters:
    ///   - shouldTrace: A flag indicating whether tracing is enabled.
    ///   - context: An optional class that provides additional context for the trace.
    ///   - action: The action that triggered the state change.
    ///   - old: The previous state before the action was applied.
    ///   - new: The new state after the action was applied.
    public func trace(
        shouldTrace: Bool,
        context: AnyClass? = nil,
        action: ViewAction,
        old: any ViewState,
        new: any ViewState
    ) {
        guard shouldTrace else { return }
        
        // Determine the name of the context or use "Unknown" if not provided.
        let contextName: String = if let context {
            String(describing: context.self)
        } else {
            "Unknown"
        }
        
        // Create a formatted string describing the context, action, and state changes.
        let event = """
        [Context: \(contextName)]
        Action Triggered: \(action)
        Changed State:
        \(compareStructs(old, new))
        """
        
        // Update the published event property with the formatted string.
        self.event = event
    }
    
    /// Compares two state objects and returns a string describing their differences.
    ///
    /// - Parameters:
    ///   - old: The previous state.
    ///   - new: The new state.
    /// - Returns: A string describing the differences between the two states,
    ///            or a message indicating no changes.
    private func compareStructs(_ old: any ViewState, _ new: any ViewState) -> String {
        var differences: String = ""
        
        // Use reflection to inspect properties of the old and new state objects.
        let oldMirror = Mirror(reflecting: old)
        let newMirror = Mirror(reflecting: new)
        
        // Compare properties one by one and identify differences.
        for (oldChild, newChild) in zip(oldMirror.children, newMirror.children) {
            guard let propertyName = oldChild.label else { continue }
            
            if isDifferent(oldChild.value, newChild.value) {
                if !differences.isEmpty {
                    differences += "\n"
                }
                differences += "\(propertyName): \(oldChild.value) -> \(newChild.value)"
            }
        }
        
        // Return the differences or indicate that there are no changes.
        return differences.isEmpty ? "There are no changes." : differences
    }
    
    /// Determines whether two values are different.
    ///
    /// - Parameters:
    ///   - lhs: The first value.
    ///   - rhs: The second value.
    /// - Returns: A boolean indicating whether the two values are different.
    private func isDifferent(_ lhs: Any, _ rhs: Any) -> Bool {
        return "\(lhs)" != "\(rhs)"
    }
}
