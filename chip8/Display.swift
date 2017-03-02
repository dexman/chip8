//
//  Display.swift
//  chip8
//
//  Created by Arthur Dexter on 3/1/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import Foundation

public struct DisplayCoordinate {
    public let x: UInt8
    public let y: UInt8
}

public protocol Display {

    func clear()

    func display(sprite: [UInt8], at coordinate: DisplayCoordinate) -> Bool

}

public class DefaultDisplay: Display {

    public func clear() {
        print("Clear the display")
    }

    public func display(sprite: [UInt8], at coordinate: DisplayCoordinate) -> Bool {
        print("Displayed \(sprite.count)-byte sprite at (\(coordinate.x),\(coordinate.y))")
        return false
    }
    
}
