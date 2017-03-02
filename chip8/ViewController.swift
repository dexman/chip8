//
//  ViewController.swift
//  CHIP8
//
//  Created by Arthur Dexter on 3/2/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import Cocoa
import CHIP8VM

class ViewController: NSViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        vm = VM(keyboard: keyboard, display: display)
        let romUrl = URL(fileURLWithPath: "/Users/adexter/Downloads/c8games/TICTAC")
        do {
            try vm?.run(withRom: romUrl)
        } catch {
            NSLog("Failed to run: \(error)")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    var vm: VM?

    @IBOutlet weak var display: NSViewDisplay!
    @IBOutlet weak var keyboard: NSViewKeyboard!

}

