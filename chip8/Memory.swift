//
//  Memory.swift
//  chip8
//
//  Created by Arthur Dexter on 3/1/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import Foundation

enum MemoryError: Error {
    case invalidAddress(Int)
}

struct Pointer {

    init(address: UInt16) throws {
        try self.init(address: Int(address))
    }

    fileprivate init(address: Int) throws {
        if address < 0 || address >= Memory.capacity {
            throw MemoryError.invalidAddress(address)
        }
        self.address = address & Memory.capacity
    }

    fileprivate let address: Int

}

class Memory: Resettable {

    static let capacity = 0xFFF

    func read(buffer: inout [UInt8], from src: Pointer) throws {
        try ensureValidMemoryRange(at: src, count: buffer.count)
        for i in 0..<buffer.count {
            buffer[i] = memory[src.address + i]
        }
    }

    func write(buffer: [UInt8], to dst: Pointer) throws {
        try ensureValidMemoryRange(at: dst, count: buffer.count)
        for i in 0..<buffer.count {
            memory[dst.address + i] = buffer[i]
        }
    }

    func reset() {
        for i in 0..<memory.count {
            memory[i] = 0
        }
    }

    private func ensureValidMemoryRange(at pointer: Pointer, count: Int) throws {
        let end = pointer.address + count - 1
        let _ = try Pointer(address: end)
    }

    private var memory = [UInt8](repeating: 0, count: Memory.capacity)

}
