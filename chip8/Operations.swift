//
//  Operations.swift
//  chip8
//
//  Created by Arthur Dexter on 3/1/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import Foundation

protocol CPUOperation {

    func execute() throws

}

// MARK: - Display

struct ClearDisplayOperation: CPUOperation {

    let display: Display

    func execute() {
        display.clear()
    }

}

struct DisplaySpriteOperation: CPUOperation {

    let registers: Registers
    let registerX: Register
    let registerY: Register
    let memory: Memory
    let display: Display
    let immediate: UInt8

    func execute() throws {
        var sprite: [UInt8] = Array(repeating: 0, count: Int(immediate))
        try memory.read(buffer: &sprite, from: Pointer(address: registers.index))

        let coordinate = DisplayCoordinate(x: registers[registerX], y: registers[registerY])
        let erasedPixels = display.display(sprite: sprite, at: coordinate)
        registers[.vF] = erasedPixels ? 0x1 : 0x0
    }

}

// MARK - Font

struct StoreSpriteForDigitToIndexRegister: CPUOperation {

    let registers: Registers
    let registerX: Register

    func execute() throws {
        let digit = registers[registerX]
        registers.index = fontAddress(of: digit)
    }

}

// MARK: - Subroutines

struct CallSubroutineOperation: CPUOperation {

    let stack: Stack
    let programCounter: ProgramCounter
    let subroutineAddress: UInt16

    func execute() throws {
        try stack.push(programCounter.address)
        programCounter.address = subroutineAddress
    }
    
}

struct ReturnFromSubroutineOperation: CPUOperation {

    let stack: Stack
    let programCounter: ProgramCounter

    func execute() throws {
        programCounter.address = try stack.pop()
    }

}

// MARK: - Jumps

struct JumpOperation: CPUOperation {

    let programCounter: ProgramCounter
    let address: UInt16

    func execute() throws {
        programCounter.address = address
    }

}

struct JumpRegisterPlusAddressOperation: CPUOperation {

    let registers: Registers
    let programCounter: ProgramCounter
    let address: UInt16

    func execute() throws {
        programCounter.address = UInt16(registers[.v0]) + address
    }
    
}

// MARK: - Skips

struct SkipRegisterEqualsImmediateOperation: CPUOperation {

    let registers: Registers
    let programCounter: ProgramCounter
    let registerX: Register
    let immediate: UInt8

    func execute() {
        if registers[registerX] == immediate {
            programCounter.increment()
        }
    }
    
}

struct SkipRegisterNotEqualsImmediateOperation: CPUOperation {

    let registers: Registers
    let programCounter: ProgramCounter
    let registerX: Register
    let immediate: UInt8

    func execute() {
        if registers[registerX] != immediate {
            programCounter.increment()
        }
    }
    
}

struct SkipRegisterEqualsRegisterOperation: CPUOperation {

    let registers: Registers
    let programCounter: ProgramCounter
    let registerX: Register
    let registerY: Register

    func execute() {
        if registers[registerX] == registers[registerY] {
            programCounter.increment()
        }
    }

}

struct SkipRegisterNotEqualsRegisterOperation: CPUOperation {

    let registers: Registers
    let programCounter: ProgramCounter
    let registerX: Register
    let registerY: Register

    func execute() {
        if registers[registerX] != registers[registerY] {
            programCounter.increment()
        }
    }
    
}

// MARK: - Keyboard

struct SkipIfKeyPressedOperation: CPUOperation {

    let registers: Registers
    let programCounter: ProgramCounter
    let keyboard: Keyboard
    let registerX: Register

    func execute() {
        let key = registers[registerX]
        if keyboard.isPressed(key: key) {
            programCounter.increment()
        }
    }
    
}

struct SkipIfKeyNotPressedOperation: CPUOperation {

    let registers: Registers
    let programCounter: ProgramCounter
    let keyboard: Keyboard
    let registerX: Register

    func execute() {
        let key = registers[registerX]
        if !keyboard.isPressed(key: key) {
            programCounter.increment()
        }
    }
    
}

struct WaitForKeyPressOperation: CPUOperation {

    let registers: Registers
    let keyboard: Keyboard
    let registerX: Register

    func execute() throws {
        registers[registerX] = keyboard.waitForKeyPress()
    }

}

// MARK: - Register Store

struct StoreImmediateToRegisterOperation: CPUOperation {

    let registers: Registers
    let registerX: Register
    let immediate: UInt8

    func execute() throws {
        registers[registerX] = immediate
    }

}

struct CopyRegisterToRegisterOperation: CPUOperation {

    let registers: Registers
    let registerX: Register
    let registerY: Register

    func execute() throws {
        registers[registerX] = registers[registerY]
    }
    
}

struct StoreAddressToIndexRegisterOperation: CPUOperation {

    let registers: Registers
    let address: UInt16

    func execute() throws {
        registers.index = address
    }

}

struct StoreDelayTimerToRegisterOperation: CPUOperation {

    let registers: Registers
    let registerX: Register

    func execute() throws {
        registers[registerX] = registers.delay
    }

}

struct StoreRegisterToDelayTimerOperation: CPUOperation {

    let registers: Registers
    let registerX: Register

    func execute() throws {
        registers.delay = registers[registerX]
    }
    
}

struct StoreRegisterToSoundTimerOperation: CPUOperation {

    let registers: Registers
    let registerX: Register

    func execute() throws {
        registers.sound = registers[registerX]
    }
    
}

struct StoreRegistersToMemoryOperation: CPUOperation {

    let registers: Registers
    let memory: Memory
    let registerX: Register

    func execute() throws {
        var buffer = [UInt8](repeating: 0, count: registerX.rawValue + 1)
        for r in Register.v0.rawValue...registerX.rawValue {
            buffer[r] = registers[Register(rawValue: r)!]
        }
        try memory.write(buffer: buffer, to: Pointer(address: registers.index))
    }

}

struct LoadMemoryToRegistersOperation: CPUOperation {

    let registers: Registers
    let memory: Memory
    let registerX: Register

    func execute() throws {
        var buffer = [UInt8](repeating: 0, count: registerX.rawValue + 1)
        try memory.read(buffer: &buffer, from: Pointer(address: registers.index))
        for r in Register.v0.rawValue...registerX.rawValue {
            registers[Register(rawValue: r)!] = buffer[r]
        }
    }
    
}

// MARK: - Arithmetic

struct AddImmediateToRegisterOperation: CPUOperation {

    let registers: Registers
    let registerX: Register
    let immediate: UInt8

    func execute() throws {
        registers[registerX] = UInt8.addWithOverflow(registers[registerX], immediate).0
    }
    
}

struct AddRegisterToRegisterOperation: CPUOperation {

    let registers: Registers
    let registerX: Register
    let registerY: Register

    func execute() throws {
        let (result, carry) = UInt8.addWithOverflow(registers[registerX], registers[registerY])
        registers[registerX] = result
        registers[.vF] = carry ? 0x1 : 0x0
    }
    
}

struct SubtractRegisterYFromRegisterXOperation: CPUOperation {

    let registers: Registers
    let registerX: Register
    let registerY: Register

    func execute() throws {
        let (result, carry) =  UInt8.subtractWithOverflow(registers[registerX], registers[registerY])
        registers[registerX] = result
        registers[.vF] = carry ? 0x0 : 0x1
    }

}

struct SubtractRegisterXFromRegisterYOperation: CPUOperation {

    let registers: Registers
    let registerX: Register
    let registerY: Register

    func execute() throws {
        let (result, carry) =  UInt8.subtractWithOverflow(registers[registerY], registers[registerX])
        registers[registerX] = result
        registers[.vF] = carry ? 0x0 : 0x1
    }
    
}

struct AddRegisterToIndexRegisterOperation: CPUOperation {

    let registers: Registers
    let registerX: Register

    func execute() throws {
        let (result, _) = UInt16.addWithOverflow(registers.index, UInt16(registers[registerX]))
        registers.index = result
    }
    
}

// MARK: - Bit Operations

struct OrRegistersOperation: CPUOperation {

    let registers: Registers
    let registerX: Register
    let registerY: Register

    func execute() throws {
        registers[registerX] = registers[registerX] | registers[registerY]
    }
    
}

struct AndRegistersOperation: CPUOperation {

    let registers: Registers
    let registerX: Register
    let registerY: Register

    func execute() throws {
        registers[registerX] = registers[registerX] & registers[registerY]
    }
    
}

struct XorRegistersOperation: CPUOperation {

    let registers: Registers
    let registerX: Register
    let registerY: Register

    func execute() throws {
        registers[registerX] = registers[registerX] ^ registers[registerY]
    }
    
}

struct ShiftRightRegisterOperation: CPUOperation {

    let registers: Registers
    let registerX: Register

    func execute() throws {
        registers[.vF] = registers[registerX] & 0x01
        registers[registerX] = registers[registerX] >> 1

    }
    
}

struct ShiftLeftRegisterOperation: CPUOperation {

    let registers: Registers
    let registerX: Register

    func execute() throws {
        registers[.vF] = registers[registerX] & 0x80 >> 7
        registers[registerX] = registers[registerX] << 1

    }
    
}

// MARK: - Random

struct RandomByteOperation: CPUOperation {

    let registers: Registers
    let registerX: Register
    let immediate: UInt8

    func execute() throws {
        let random = UInt8(truncatingBitPattern: arc4random())
        registers[registerX] = random & immediate
    }

}

// MARK: - Binary Coded Decimal

struct StoreBinaryCodedDecimalToMemory: CPUOperation {

    let registers: Registers
    let memory: Memory
    let registerX: Register

    func execute() throws {
        var value = registers[registerX]
        var buffer = [UInt8](repeating: 0, count: 3)
        for i in 0...2 {
            buffer[2 - i] = value % 10
            value /= 10
        }
        try memory.write(buffer: buffer, to: Pointer(address: registers.index))
    }

}
