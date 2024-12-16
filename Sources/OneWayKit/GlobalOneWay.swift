//
//  GlobalOneWay.swift
//  
//
//  Created by 안영훈 on 11/23/24.
//
import Foundation
import Combine

protocol GlobalHandlable {
    associatedtype State: FeatureState
    associatedtype Action: FeatureAction
    
    var state: State { get }
    var subject: CurrentValueSubject<State, Never> { get }
    
    func send(_ action: Action)
}

public final class GlobalOneWay: NSObject {

    private static var globalOneWays: [String: any GlobalHandlable] = [:]
    
    public static func statePublisher<Feature: Featurable>(feature: Feature.Type) -> AnyPublisher<Feature.State, Never> {
        guard let oneWay = globalOneWays[Feature.id] as? OneWay<Feature> else {
            print("The initial state for the GlobalType \(feature) has not been registered.")
            return Empty().eraseToAnyPublisher()
        }
        
        return oneWay.subject.eraseToAnyPublisher()
    }
    
    public static func state<Feature: Featurable>(feature: Feature.Type) -> CurrentValueSubject<Feature.State, Never>? {
        guard let oneWay = globalOneWays[Feature.id] as? OneWay<Feature> else {
            print("The initial state for the GlobalType \(feature) has not been registered.")
            return nil
        }
        
        return oneWay.subject
    }
    
    public static func send<Feature: Featurable>(feature: Feature.Type, _ action: Feature.Action) {
        guard let oneWay = globalOneWays[Feature.id] as? OneWay<Feature> else {
            return
        }
        
        oneWay.send(action)
    }
    
    public static func registerState<Feature: Featurable>(feature: Feature.Type, initialState: Feature.State) {
        guard globalOneWays[Feature.id] == nil else { return }
        globalOneWays[Feature.id] = OneWay<Feature>(initialState: initialState)
    }
}
