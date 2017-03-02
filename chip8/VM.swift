//
//  VM.swift
//  chip8
//
//  Created by Arthur Dexter on 3/2/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import Foundation

public class VM {

    public init(keyboard: Keyboard = DefaultKeyboard(), display: Display = DefaultDisplay()) {
        let memory = Memory()
        self.cpu = CPU(memory: memory, keyboard: keyboard, display: display)
        self.memory = memory
        self.keyboard = keyboard
        self.display = display

        self.cpuQueue = DispatchQueue(label: "CHIP8VM.VM.cpu")
    }

    public func run(withRom url: URL) throws {
        rom = { [UInt8](try Data(contentsOf: url)) }
        try reset()
    }

    public func reset() throws {
        cpuTimer?.cancel()
        cpu.reset()
        memory.reset()
        try storeFont(in: memory)
        try reloadROM()
        runCpu()
    }

    private let cpu: CPU
    private let memory: Memory
    private let keyboard: Keyboard
    private let display: Display

    private var rom: (() throws -> [UInt8])?

    private let cpuQueue: DispatchQueue
    private var cpuTimer: DispatchSourceTimer?

    private func reloadROM() throws {
        if let rom = rom {
            try memory.write(buffer: rom(), to: Pointer(address: ProgramCounter.defaultAddress))
        }
    }

    private func runCpu() {
        cpuTimer = DispatchSource.makeTimerSource(queue: cpuQueue)
        cpuTimer?.scheduleRepeating(
            deadline: .now(),
            interval: .milliseconds(1),
            leeway: .nanoseconds(1))
        cpuTimer?.setEventHandler { [weak self] in
            do {
                try self?.cpu.cycle()
            } catch {
                self?.cpuTimer?.cancel()
            }
        }
        cpuTimer?.resume()
    }

}

protocol Resettable {

    func reset()

}
