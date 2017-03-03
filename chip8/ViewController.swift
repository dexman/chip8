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
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func openDocument(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.begin { result in
            if result == NSFileHandlingPanelOKButton, let url = panel.url {
                self.run(witihRom: url)
            }
        }
    }

    private var vm: VM?

    @IBOutlet weak var display: NSViewDisplay!
    @IBOutlet weak var keyboard: NSViewKeyboard!

    private func run(witihRom romUrl: URL) {
        do {
            try vm?.run(withRom: romUrl)
        } catch {
            NSLog("Failed to run: \(error)")
        }
    }

}

