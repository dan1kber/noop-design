// Draws the W3P "Dot W" app icon. Run on macOS: swift make-icon.swift
import AppKit

func icon(_ px: Int) -> Data {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!.cgContext
    let space = CGColorSpaceCreateDeviceRGB()
    func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
        CGColor(colorSpace: space, components: [r / 255, g / 255, b / 255, a])!
    }
    // Flip to a top-left origin so the dot grid reads like the SVG it mirrors.
    ctx.translateBy(x: 0, y: s); ctx.scaleBy(x: 1, y: -1)
    let lin = CGGradient(colorsSpace: space, colors: [rgb(91, 61, 255), rgb(255, 90, 43)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(lin, start: CGPoint(x: s * 0.2, y: 0), end: CGPoint(x: s * 0.8, y: s), options: [])
    let pink = CGGradient(colorsSpace: space, colors: [rgb(255, 134, 220), rgb(255, 134, 220, 0)] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(pink, startCenter: CGPoint(x: s * 0.18, y: 0), startRadius: 0,
                           endCenter: CGPoint(x: s * 0.18, y: 0), endRadius: s * 0.6, options: [])
    let core = CGGradient(colorsSpace: space,
                          colors: [rgb(4, 5, 9, 0.97), rgb(4, 5, 9, 0.97), rgb(4, 5, 9, 0.5), rgb(4, 5, 9, 0)] as CFArray,
                          locations: [0, 0.4, 0.7, 1])!
    ctx.saveGState()
    ctx.translateBy(x: s * 0.5, y: s * 0.56); ctx.scaleBy(x: 0.82, y: 0.72)
    ctx.drawRadialGradient(core, startCenter: .zero, startRadius: 0, endCenter: .zero, endRadius: s, options: [])
    ctx.restoreGState()
    let rows = ["X.....X", "X.....X", "X..X..X", "X..X..X", "X.X.X.X", ".X...X."]
    let u = s / 100
    for (y, row) in rows.enumerated() {
        for (x, c) in row.enumerated() where c == "X" {
            let lime = x == 3 && y == 2
            let r = (lime ? 4.4 : 3.7) * u
            ctx.setFillColor(lime ? rgb(228, 240, 74) : rgb(255, 255, 255))
            ctx.fillEllipse(in: CGRect(x: (20 + CGFloat(x) * 10) * u - r, y: (25 + CGFloat(y) * 10) * u - r, width: 2 * r, height: 2 * r))
        }
    }
    return rep.representation(using: .png, properties: [:])!
}

for (name, px) in [("Icon-60@2x.png", 120), ("Icon-60@3x.png", 180)] {
    try! icon(px).write(to: URL(fileURLWithPath: name))
}
