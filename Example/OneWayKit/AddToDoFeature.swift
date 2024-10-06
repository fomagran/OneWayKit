//
//  AddToDoFeature.swift
//  OneWayKit_Example
//
//  Created by Fomagran on 10/6/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import OneWayKit

struct AddToDoFeature: Featurable {
    static var id: String = "AddToDoFeature"
    
    struct State: FeatureState {}
    
    enum Action: FeatureAction {
        case add(String)
    }
    
    static var updater: Updater = { state, action in
        switch action {
        default: break
        }
        
        return state
    }
    
    static var asyncActions: [AsyncAction]?
}
