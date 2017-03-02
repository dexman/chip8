//
//  Keyboard.swift
//  chip8
//
//  Created by Arthur Dexter on 3/2/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import Foundation

public protocol Keyboard {

    func isPressed(key: UInt8) -> Bool

    func waitForKeyPress() -> UInt8

}

public class DefaultKeyboard: Keyboard {

    public func isPressed(key: UInt8) -> Bool {
        return false
    }

    public func waitForKeyPress() -> UInt8 {
        return 0
    }

}
