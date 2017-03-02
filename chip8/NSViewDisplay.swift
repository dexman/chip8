//
//  NSViewDisplay.swift
//  chip8
//
//  Created by Arthur Dexter on 3/2/17.
//  Copyright © 2017 LivingSocial. All rights reserved.
//

import CHIP8VM
import CoreGraphics
import Foundation

@IBDesignable class NSViewDisplay: NSView, Display {

    deinit {
        bitmapBuffer.deallocate(capacity: bufferSize)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        redrawBackingBitmap()
    }

    func clear() {
        NSLog("clear")
        drawingQueue.async { [weak self] in
            for i in 0 ..< bufferSize {
                self?.bitmapBuffer[i] = 0
            }
            self?.redrawBackingBitmap()
        }
    }

    func display(sprite: [UInt8], at coordinate: DisplayCoordinate) -> Bool {
        NSLog("display")
        var erased = false
        drawingQueue.sync {
            for spriteY in 0..<sprite.count {
                let spriteRow = sprite[spriteY]
                for spriteX in 0..<8 {
                    let bitmapBufferIndex = (spriteY + Int(coordinate.y)) * Int(displayWidth) + (spriteX + Int(coordinate.x))
                    let spritePixel: UInt32 = (spriteRow >> UInt8(7 - spriteX)) & 0x1 == 0x1 ? 0xffffffff : 0
                    let bitmapPixel: UInt32 = bitmapBuffer[bitmapBufferIndex]
                    bitmapBuffer[bitmapBufferIndex] = spritePixel ^ bitmapPixel
                    if bitmapPixel != 0 && bitmapBuffer[bitmapBufferIndex] == 0 {
                        erased = true
                    }
                }
            }
            redrawBackingBitmap()
        }
        return erased
    }

    func redrawBackingBitmap() {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        let optionalContext = CGContext(
            data: bitmapBuffer,
            width: displayWidth,
            height: displayHeight,
            bitsPerComponent: 8,
            bytesPerRow: displayWidth * MemoryLayout<UInt32>.size,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue)
        guard let context = optionalContext else {
            NSLog("Failed to create bitmap context.")
            return
        }
        guard let image = context.makeImage() else {
            NSLog("Failed to create image")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.layer?.magnificationFilter = kCAFilterNearest
            this.layer?.contents = image
            this.setNeedsDisplay(this.bounds)
        }
    }

    private let drawingQueue = DispatchQueue(label: "NSViewDisplay.drawing")
    private let bitmapBuffer: UnsafeMutablePointer<UInt32> = {
        let bitmapBuffer = UnsafeMutablePointer<UInt32>.allocate(capacity: bufferSize)
        for i in 0 ..< bufferSize {
            bitmapBuffer[i] = 0
        }
        return bitmapBuffer
    }()

}

private let displayWidth = 64
private let displayHeight = 32
private let bufferSize = displayWidth * displayHeight
