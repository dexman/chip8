//
//  ProgramCounter.swift
//  chip8
//
//  Created by Arthur Dexter on 3/1/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import Foundation

class ProgramCounter: Resettable {

    static let defaultAddress: UInt16 = 0x200

    var address: UInt16 = ProgramCounter.defaultAddress

    func increment() {
        address += 2
    }

    func reset() {
        address = ProgramCounter.defaultAddress
    }

}
