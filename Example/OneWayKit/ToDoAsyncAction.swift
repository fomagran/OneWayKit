//
//  ToDoAsyncAction.swift
//  OneWayKit_Example
//
//  Created by Fomagran on 10/6/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import OneWayKit
import Combine

final class ToDoAsyncAction: AsyncAction {
    func send(_ action: FeatureAction, currentState: FeatureState) -> AnyPublisher<FeatureAction, Never> {
        
        switch action as? ToDoFeature.Action {
            
        case .reserveToDo(let seconds):
            return Just(ToDoFeature.Action.add("Reserved To-Do"))
                  .delay(for: .seconds(seconds), scheduler: RunLoop.main)
                  .eraseToAnyPublisher()
            
        case .addToDoPerSecond(let seconds):
            return Timer.publish(every: seconds, on: .main, in: .commonModes)
                 .autoconnect()
                 .map { _ in ToDoFeature.Action.add("Add To Do Per Seconds: \(seconds)") }
                 .eraseToAnyPublisher()
            
        default:
            return Empty().eraseToAnyPublisher()
        }
    }
    
}
