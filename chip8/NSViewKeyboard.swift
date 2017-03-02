//
//  NSViewKeyboard.swift
//  chip8
//
//  Created by Arthur Dexter on 3/2/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import CHIP8VM
import Foundation

@IBDesignable class NSViewKeyboard: NSView, Keyboard {

    override func awakeFromNib() {
        super.awakeFromNib()

        var rows = NSStackView()
        rows.distribution = .fillEqually
        rows.orientation = .vertical
        rows.spacing = 8.0
        addSubview(rows)

        func makeRow() {
            let row = NSStackView()
            row.distribution = .fillEqually
            row.orientation = .horizontal
            row.spacing = 8.0
            rows.addArrangedSubview(row)
        }

        var previousKey: NSView?
        for (i, key) in keys.enumerated() {
            if i % 4 == 0 {
                makeRow()
            }
            guard let row = rows.arrangedSubviews.last as? NSStackView else { return }
            row.addArrangedSubview(key)

            if let previousKey = previousKey {
                key.widthAnchor.constraint(equalTo: previousKey.widthAnchor).isActive = true
                key.heightAnchor.constraint(equalTo: previousKey.heightAnchor).isActive = true
            }

            previousKey = key
        }

        rows.translatesAutoresizingMaskIntoConstraints = false
        rows.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func isPressed(key: UInt8) -> Bool {
        var pressed = false
        DispatchQueue.main.sync {
            pressed = keys[Int(key & 0xF)].isHighlighted
        }
        return pressed
    }

    func waitForKeyPress() -> UInt8 {
        NSLog("simulator waiting for key")
        keyPressSemaphore.wait()
        var key: UInt8 = 0
        DispatchQueue.main.sync {
            key = lastKeyPressed
        }
        NSLog("Sending simulator key=\(key)")
        return key
    }

    private let keyPressSemaphore = DispatchSemaphore(value: 0)

    private var lastKeyPressed: UInt8 = 0

    private lazy var keys: [NSButton] = {
        let values = [
            0x1, 0x2, 0x3, 0xC,
            0x4, 0x5, 0x6, 0xD,
            0x7, 0x8, 0x9, 0xE,
            0xA, 0x0, 0xB, 0xF
        ]
        return values.map { i in
            let button = NSButton(title: String(format: "%2X", i), target: self, action: #selector(NSViewKeyboard.keyPressed(_:)))
            button.tag = i
            return button
        }
    }()

    @objc private func keyPressed(_ sender: NSButton) {
        lastKeyPressed = UInt8(sender.tag)
        keyPressSemaphore.signal()
    }

}
