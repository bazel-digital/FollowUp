//
//  Sequence+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 17/10/2021.
//

import Foundation

extension Sequence {
    func grouped<Value: Hashable>(by keyPath: KeyPath<Element, Value>) -> [Value: [Element]] {
        self.reduce(into: [:]) { partialResult, element in
            partialResult[element[keyPath: keyPath], default: []].append(element)
        }
    }

    func mappedToDictionary<Key>(by keyPath: KeyPath<Element, Key>) -> Dictionary<Key, Element> {
        self.reduce(into: [:]) { partialResult, item in
            partialResult[item[keyPath: keyPath]] = item
        }
    }
}
