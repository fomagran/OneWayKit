//
//  OneWay+Store.swift
//
//
//  Created by Fomagran on 10/12/24.
//

import Combine

extension OneWay {
    func key(_ action: ViewAction) -> String {
        return "\(Feature.id) + \(action)"
    }
}

extension AnyCancellable {
    func store(in dictionary: inout [String: AnyCancellable], key: String) {
        dictionary[key] = self
    }
}
