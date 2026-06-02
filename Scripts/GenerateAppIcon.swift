import AppKit
import CoreGraphics
import Foundation

let size = 1024
let outputPath = "TapJail/Resources/Assets.xcassets/AppIcon.appiconset/TapJailIcon.png"
let colorSpace = CGColorSpaceCreateDeviceRGB()

guard
    let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )
else {
    fatalError("Could not create icon context.")
}

context.setFillColor(NSColor.black.cgColor)
context.fill(CGRect(x: 0, y: 0, width: size, height: size))

let circleDiameter = CGFloat(size) * 0.72
let circleRect = CGRect(
    x: (CGFloat(size) - circleDiameter) / 2,
    y: (CGFloat(size) - circleDiameter) / 2,
    width: circleDiameter,
    height: circleDiameter
)

context.setFillColor(NSColor(red: 209 / 255, green: 0, blue: 0, alpha: 1).cgColor)
context.fillEllipse(in: circleRect)

context.saveGState()
context.addEllipse(in: circleRect)
context.clip()

let barHeight: CGFloat = 34
let gap: CGFloat = circleDiameter * 0.18
let centerY = CGFloat(size) / 2
let barWidth = circleDiameter
let barX = circleRect.minX

context.setFillColor(NSColor.white.cgColor)
for offset in [-gap, 0, gap] {
    let rect = CGRect(
        x: barX,
        y: centerY + offset - barHeight / 2,
        width: barWidth,
        height: barHeight
    )
    context.fill(rect)
}

context.restoreGState()

guard let image = context.makeImage() else {
    fatalError("Could not create icon image.")
}

let bitmap = NSBitmapImageRep(cgImage: image)
guard let data = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not encode icon PNG.")
}

try data.write(to: URL(fileURLWithPath: outputPath))

