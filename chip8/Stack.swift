//
//  Stack.swift
//  chip8
//
//  Created by Arthur Dexter on 3/1/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import Foundation

enum StackError: Error {
    case Overflow
    case Underflow
}

class Stack: Resettable {

    static let capacity = 16

    init() {
        stack.reserveCapacity(Stack.capacity)
    }

    func push(_ value: UInt16) throws {
        if stack.count >= Stack.capacity {
            throw StackError.Overflow
        }
        stack.append(value)
    }

    func pop() throws -> UInt16 {
        guard let value = stack.popLast() else {
            throw StackError.Underflow
        }
        return value
    }

    func reset() {
        stack.removeAll(keepingCapacity: true)
    }

    private var stack: [UInt16] = []
    
}
