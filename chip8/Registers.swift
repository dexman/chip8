//
//  Registers.swift
//  chip8
//
//  Created by Arthur Dexter on 3/1/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import Foundation

enum Register: Int {

    case v0
    case v1
    case v2
    case v3
    case v4
    case v5
    case v6
    case v7
    case v8
    case v9
    case vA
    case vB
    case vC
    case vD
    case vE
    case vF

    static var count: Int {
        return Register.vF.rawValue + 1
    }

}

class Registers: Resettable {

    subscript(register: Register) -> UInt8 {
        get {
            return registers[register.rawValue]
        }
        set {
            registers[register.rawValue] = newValue
        }
    }

    var index: UInt16 = 0

    var delay: UInt8 = 0

    var sound: UInt8 = 0

    func reset() {
        for i in 0..<registers.count {
            registers[i] = 0
        }
        index = 0
        delay = 0
        sound = 0
    }

    private var registers: [UInt8] = [UInt8](repeating: 0, count: Register.count)

}
