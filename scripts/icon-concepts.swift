// Granite State Eats icon concepts (2026-11-06), drawn in the shared Eats Ranked style (state-prompts/ICON-STYLE.md): one flat, level,
// centred food on granite #3E4A52 (the palette in Design/Theme.swift), no backing shape, no text or texture, no state seal and no Old
// Man of the Mountain. Food hexes: pancake #E7B66B with its lighter top #F3D49A, maple syrup #9A4A12, butter #F7E39A; cider donut
// #C98A4B with its sugared top #E2B27C and the hole cut to granite, leaf #4F7A3A; tenders #D99A45 with lighter tops #EDBE6E, basket
// #B5471B (the palette's foliage orange) with its liner #F6F4EF.
//   A  a short stack of pancakes with a maple-syrup drip and a pat of butter, side view
//   B  an apple cider donut, front view, with one apple leaf
//   C  a basket of chicken tenders, side view
// Usage, from nh-eats/: swift scripts/icon-concepts.swift <out dir>   -> concept-{a,b,c}-1024.png
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
}
let GRANITE: UInt32 = 0x3E4A52, CAKE: UInt32 = 0xE7B66B, CAKETOP: UInt32 = 0xF3D49A, SYRUP: UInt32 = 0x9A4A12, BUTTER: UInt32 = 0xF7E39A
let DONUT: UInt32 = 0xC98A4B, SUGAR: UInt32 = 0xE2B27C, LEAF: UInt32 = 0x4F7A3A
let TENDER: UInt32 = 0xD99A45, TENDERTOP: UInt32 = 0xEDBE6E, BASKET: UInt32 = 0xB5471B, LINER: UInt32 = 0xF6F4EF

/// A: the pancake stack. CoreGraphics y-up, s = canvas size. Identical to make-brand.swift's pancakes().
func pancakes(_ c: CGContext, _ s: CGFloat) {
    c.saveGState(); defer { c.restoreGState() }
    c.translateBy(x: 0, y: 0.012 * s)   // mass a little low, within the band the references sit in
    func R(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) -> CGPath {
        CGPath(roundedRect: CGRect(x: x * s, y: y * s, width: w * s, height: h * s), cornerWidth: r * s, cornerHeight: r * s, transform: nil)
    }
    // three cakes, each a soft capsule with a lighter top face, stacked level
    for (i, y) in [0.29, 0.39, 0.49].enumerated() {
        let inset = CGFloat(i) * 0.012
        c.setFillColor(rgb(CAKE)); c.addPath(R(0.14 + inset, y, 0.72 - 2 * inset, 0.095, 0.0475)); c.fillPath()
        c.setFillColor(rgb(CAKETOP)); c.addPath(R(0.17 + inset, y + 0.055, 0.66 - 2 * inset, 0.034, 0.017)); c.fillPath()
    }
    // syrup pooled on top, running down the front in two drips
    c.setFillColor(rgb(SYRUP)); c.addPath(R(0.20, 0.555, 0.60, 0.05, 0.025)); c.fillPath()
    c.setStrokeColor(rgb(SYRUP)); c.setLineWidth(0.04 * s); c.setLineCap(.round)
    for (x, l) in [(0.30, 0.13), (0.66, 0.20)] as [(CGFloat, CGFloat)] {
        c.move(to: CGPoint(x: x * s, y: 0.57 * s)); c.addLine(to: CGPoint(x: x * s, y: (0.57 - l) * s)); c.strokePath()
    }
    // a pat of butter, level on top
    c.setFillColor(rgb(BUTTER)); c.addPath(R(0.42, 0.595, 0.16, 0.07, 0.015)); c.fillPath()
}

/// B: an apple cider donut, front view: the ring, its sugared top half as the lighter plane, the hole cut through, one leaf.
func ciderDonut(_ c: CGContext, _ s: CGFloat) {
    let cx = 0.5 * s, cy = 0.45 * s, r = 0.355 * s
    c.setFillColor(rgb(DONUT)); c.fillEllipse(in: CGRect(x: cx - r, y: cy - r * 0.92, width: 2 * r, height: 2 * r * 0.92))
    c.saveGState(); c.clip(to: CGRect(x: 0, y: cy, width: s, height: s))
    c.setFillColor(rgb(SUGAR)); c.fillEllipse(in: CGRect(x: cx - r, y: cy - r * 0.92, width: 2 * r, height: 2 * r * 0.92))
    c.restoreGState()
    let h = 0.105 * s
    c.setFillColor(rgb(GRANITE)); c.fillEllipse(in: CGRect(x: cx - h, y: cy - h * 0.9, width: 2 * h, height: 2 * h * 0.9))
    let leaf = CGMutablePath()
    leaf.move(to: CGPoint(x: 0.54 * s, y: 0.75 * s))
    leaf.addQuadCurve(to: CGPoint(x: 0.72 * s, y: 0.83 * s), control: CGPoint(x: 0.60 * s, y: 0.87 * s))
    leaf.addQuadCurve(to: CGPoint(x: 0.54 * s, y: 0.75 * s), control: CGPoint(x: 0.68 * s, y: 0.73 * s))
    c.setFillColor(rgb(LEAF)); c.addPath(leaf); c.fillPath()
}

/// C: a basket of chicken tenders: four tenders standing in a paper-lined basket, side view.
func tenders(_ c: CGContext, _ s: CGFloat) {
    func R(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) -> CGPath {
        CGPath(roundedRect: CGRect(x: x * s, y: y * s, width: w * s, height: h * s), cornerWidth: r * s, cornerHeight: r * s, transform: nil)
    }
    for (x, top) in [(0.22, 0.70), (0.36, 0.74), (0.50, 0.71), (0.64, 0.73)] as [(CGFloat, CGFloat)] {
        c.setFillColor(rgb(TENDER)); c.addPath(R(x, 0.40, 0.13, top - 0.40, 0.065)); c.fillPath()
        c.setFillColor(rgb(TENDERTOP)); c.addPath(R(x + 0.025, top - 0.09, 0.08, 0.06, 0.03)); c.fillPath()
    }
    let basket = CGMutablePath()
    basket.move(to: CGPoint(x: 0.14 * s, y: 0.50 * s)); basket.addLine(to: CGPoint(x: 0.86 * s, y: 0.50 * s))
    basket.addLine(to: CGPoint(x: 0.78 * s, y: 0.28 * s)); basket.addLine(to: CGPoint(x: 0.22 * s, y: 0.28 * s)); basket.closeSubpath()
    c.setFillColor(rgb(BASKET)); c.addPath(basket); c.fillPath()
    c.setFillColor(rgb(LINER)); c.fill(CGRect(x: 0.14 * s, y: 0.47 * s, width: 0.72 * s, height: 0.035 * s))
}

func render(_ n: Int, _ path: String, _ draw: (CGContext, CGFloat) -> Void) {
    let ctx = CGContext(data: nil, width: n, height: n, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setShouldAntialias(true)
    ctx.setFillColor(rgb(GRANITE)); ctx.fill(CGRect(x: 0, y: 0, width: n, height: n))
    draw(ctx, CGFloat(n))
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "playbook/brand"
render(1024, out + "/concept-a-1024.png", pancakes)
render(1024, out + "/concept-b-1024.png", ciderDonut)
render(1024, out + "/concept-c-1024.png", tenders)
