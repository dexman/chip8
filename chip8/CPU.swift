//
//  CPU.swift
//  chip8
//
//  Created by Arthur Dexter on 3/1/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import Foundation

class CPU: Resettable {

    enum CPUError: Error {
        case invalidInstruction(Instruction)
    }

    let registers = Registers()

    let programCounter = ProgramCounter()

    let stack = Stack()

    let memory: Memory

    let display: Display

    let keyboard: Keyboard

    init(memory: Memory, keyboard: Keyboard, display: Display) {
        self.memory = memory
        self.keyboard = keyboard
        self.display = display
    }

    func cycle() throws {
        let instruction = try fetchNextInstruction()
        let operation = try decode(instruction)
        try operation.execute()
        // TODO Timers.
    }

    func reset() {
        registers.reset()
        programCounter.reset()
        stack.reset()
    }

    private func fetchNextInstruction() throws -> Instruction {
        var buffer = [UInt8](repeating: 0, count: 2)
        try memory.read(buffer: &buffer, from: Pointer(address: programCounter.address))
        let instruction: UInt16 = (UInt16(buffer[0]) << 8) | UInt16(buffer[1])
        programCounter.increment()
        return Instruction(instruction: instruction)
    }

    private func decode(_ instruction: Instruction) throws -> CPUOperation {
        switch instruction.opcode {
        case 0x0:
            switch instruction.instruction {
            case 0x00E0:
                return ClearDisplayOperation(display: display)
            case 0x00EE:
                return ReturnFromSubroutineOperation(
                    stack: stack,
                    programCounter: programCounter)
            default:
                break
            }
        case 0x1:
            return JumpOperation(
                programCounter: programCounter,
                address: instruction.address)
        case 0x2:
            return CallSubroutineOperation(
                stack: stack,
                programCounter: programCounter,
                subroutineAddress: instruction.address)
        case 0x3:
            return SkipRegisterEqualsImmediateOperation(
                registers: registers,
                programCounter: programCounter,
                registerX: instruction.registerX,
                immediate: instruction.immediateByte)
        case 0x4:
            return SkipRegisterNotEqualsImmediateOperation(
                registers: registers,
                programCounter: programCounter,
                registerX: instruction.registerX,
                immediate: instruction.immediateByte)
        case 0x5:
            return SkipRegisterEqualsRegisterOperation(
                registers: registers,
                programCounter: programCounter,
                registerX: instruction.registerX,
                registerY: instruction.registerY)
        case 0x6:
            return StoreImmediateToRegisterOperation(
                registers: registers,
                registerX: instruction.registerX,
                immediate: instruction.immediateByte)
        case 0x7:
            return AddImmediateToRegisterOperation(
                registers: registers,
                registerX: instruction.registerX,
                immediate: instruction.immediateByte)
        case 0x8:
            switch instruction.immediateNibble {
            case 0x0:
                return CopyRegisterToRegisterOperation(
                    registers: registers,
                    registerX: instruction.registerX,
                    registerY: instruction.registerY)
            case 0x1:
                return OrRegistersOperation(
                    registers: registers,
                    registerX: instruction.registerX,
                    registerY: instruction.registerY)
            case 0x2:
                return AndRegistersOperation(
                    registers: registers,
                    registerX: instruction.registerX,
                    registerY: instruction.registerY)
            case 0x3:
                return XorRegistersOperation(
                    registers: registers,
                    registerX: instruction.registerX,
                    registerY: instruction.registerY)
            case 0x4:
                return AddRegisterToRegisterOperation(
                    registers: registers,
                    registerX: instruction.registerX,
                    registerY: instruction.registerY)
            case 0x5:
                return SubtractRegisterYFromRegisterXOperation(
                    registers: registers,
                    registerX: instruction.registerX,
                    registerY: instruction.registerY)
            case 0x6:
                return ShiftRightRegisterOperation(
                    registers: registers,
                    registerX: instruction.registerX)
            case 0x7:
                return SubtractRegisterXFromRegisterYOperation(
                    registers: registers,
                    registerX: instruction.registerX,
                    registerY: instruction.registerY)
            case 0xE:
                return ShiftLeftRegisterOperation(
                    registers: registers,
                    registerX: instruction.registerX)
            default:
                break
            }
        case 0x9:
            return SkipRegisterNotEqualsRegisterOperation(
                registers: registers,
                programCounter: programCounter,
                registerX: instruction.registerX,
                registerY: instruction.registerY)
        case 0xA:
            return StoreAddressToIndexRegisterOperation(
                registers: registers,
                address: instruction.address)
        case 0xB:
            return JumpRegisterPlusAddressOperation(
                registers: registers,
                programCounter: programCounter,
                address: instruction.address)
        case 0xC:
            return RandomByteOperation(
                registers: registers,
                registerX: instruction.registerX,
                immediate: instruction.immediateByte)
        case 0xD:
            return DisplaySpriteOperation(
                registers: registers,
                registerX: instruction.registerX,
                registerY: instruction.registerY,
                memory: memory,
                display: display,
                immediate: instruction.immediateNibble)
        case 0xE:
            switch instruction.immediateByte {
            case 0x9E:
                return SkipIfKeyPressedOperation(
                    registers: registers,
                    programCounter: programCounter,
                    keyboard: keyboard,
                    registerX: instruction.registerX)
            case 0xA1:
                return SkipIfKeyNotPressedOperation(
                    registers: registers,
                    programCounter: programCounter,
                    keyboard: keyboard,
                    registerX: instruction.registerX)
            default:
                break
            }
        case 0xF:
            switch instruction.immediateByte {
            case 0x07:
                return StoreDelayTimerToRegisterOperation(
                    registers: registers,
                    registerX: instruction.registerX)
            case 0x0A:
                return WaitForKeyPressOperation(
                    registers: registers,
                    keyboard: keyboard,
                    registerX: instruction.registerX)
            case 0x15:
                return StoreRegisterToDelayTimerOperation(
                    registers: registers,
                    registerX: instruction.registerX)
            case 0x18:
                return StoreRegisterToSoundTimerOperation(
                    registers: registers,
                    registerX: instruction.registerX)
            case 0x1E:
                return AddRegisterToIndexRegisterOperation(
                    registers: registers,
                    registerX: instruction.registerX)
            case 0x29:
                return StoreSpriteForDigitToIndexRegister(
                    registers: registers,
                    registerX: instruction.registerX)
            case 0x33:
                return StoreBinaryCodedDecimalToMemory(
                    registers: registers,
                    memory: memory,
                    registerX: instruction.registerX)
            case 0x55:
                return StoreRegistersToMemoryOperation(
                    registers: registers,
                    memory: memory,
                    registerX: instruction.registerX)
            case 0x65:
                return LoadMemoryToRegistersOperation(
                    registers: registers,
                    memory: memory,
                    registerX: instruction.registerX)
            default:
                break
            }
        default:
            break
        }

        throw CPUError.invalidInstruction(instruction)
    }

}

struct Instruction {

    let instruction: UInt16

    var opcode: UInt8 {
        return UInt8((instruction & 0xF000) >> 12)
    }

    var address: UInt16 {
        return instruction & 0x0FFF
    }

    var registerX: Register {
        return Register(rawValue: (Int(instruction) & 0x0F00) >> 8)!
    }

    var registerY: Register {
        return Register(rawValue: (Int(instruction) & 0x00F0) >> 4)!
    }

    var immediateByte: UInt8 {
        return UInt8(instruction & 0x00FF)
    }

    var immediateNibble: UInt8 {
        return UInt8(instruction & 0x000F)
    }

}
