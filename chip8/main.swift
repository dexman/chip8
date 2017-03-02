//
//  main.swift
//  chip8
//
//  Created by Arthur Dexter on 3/2/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import Foundation
import CHIP8VM

do {
    let romUrl = URL(fileURLWithPath: "/Users/adexter/Downloads/c8games/TICTAC")
    let vm = VM()
    try vm.run(withRom: romUrl)
} catch {
    print("Failed: \(error)")
}
