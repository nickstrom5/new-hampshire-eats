// Granite State Eats brand (provisional, 2026-11-06; Nick picks the name, icon and palette): the app icon is concept A of
// scripts/icon-concepts.swift, a short stack of pancakes with maple syrup and a pat of butter, on granite; the shared Eats Ranked icon
// style, state-prompts/ICON-STYLE.md, no backing shape. No state seal, no Old Man of the Mountain, no "Live Free or Die", no team marks.
// Usage, from nh-eats/: swift scripts/make-brand.swift   -> NewHampshireEats/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png,
// docs/ favicons and touch icons, docs/og.png. scripts/make-site.py draws the same mark as its inline SVG: change both together.
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
}
let GRANITE: UInt32 = 0x3E4A52, CAKE: UInt32 = 0xE7B66B, CAKETOP: UInt32 = 0xF3D49A, SYRUP: UInt32 = 0x9A4A12, BUTTER: UInt32 = 0xF7E39A
let FOLIAGE: UInt32 = 0xB5471B, BIRCH: UInt32 = 0xF6F4EF

/// The pancake stack (concept A of icon-concepts.swift; keep the two identical). CoreGraphics y-up, s = canvas size.
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


func render(_ n: Int, _ path: String, background: Bool) {
    let ctx = CGContext(data: nil, width: n, height: n, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: background ? CGImageAlphaInfo.noneSkipLast.rawValue : CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setShouldAntialias(true)
    if background { ctx.setFillColor(rgb(GRANITE)); ctx.fill(CGRect(x: 0, y: 0, width: n, height: n)) }
    pancakes(ctx, CGFloat(n))
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}
render(1024, "NewHampshireEats/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png", background: true)
try? FileManager.default.createDirectory(atPath: "docs", withIntermediateDirectories: true)
for (n, name) in [(512, "icon-512.png"), (192, "icon-192.png"), (180, "apple-touch-icon.png"), (32, "favicon-32.png")] {
    render(n, "docs/" + name, background: true)
}

/// The share image (1200 x 630): granite, the stack at the left, the name and tagline at the right, and the app's header band along the
/// bottom: the Presidential Range in two layers over a foliage baseline, on birch white (Theme.swift's Stripes.ridges).
func og(_ path: String) {
    let W = 1200, H = 630
    let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setShouldAntialias(true)
    ctx.setFillColor(rgb(GRANITE)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    let band: CGFloat = 70, base: CGFloat = 14
    ctx.setFillColor(rgb(BIRCH)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: Int(band)))
    let ridges: [[(CGFloat, CGFloat)]] = [
        [(0, 0.55), (0.10, 0.70), (0.22, 0.58), (0.35, 0.80), (0.50, 0.66), (0.66, 0.84), (0.80, 0.62), (0.92, 0.74), (1, 0.60)],
        [(0, 0.20), (0.14, 0.42), (0.28, 0.30), (0.40, 0.62), (0.47, 0.75), (0.52, 1.0), (0.58, 0.78), (0.66, 0.52), (0.80, 0.36),
         (0.92, 0.46), (1, 0.28)]]
    for (i, ridge) in ridges.enumerated() {
        let p = CGMutablePath(); p.move(to: CGPoint(x: 0, y: base))
        for (x, rise) in ridge { p.addLine(to: CGPoint(x: x * CGFloat(W), y: base + (band - base) * rise)) }
        p.addLine(to: CGPoint(x: CGFloat(W), y: base)); p.closeSubpath()
        ctx.setFillColor(rgb(GRANITE).copy(alpha: [0.45, 1.0][i])!); ctx.addPath(p); ctx.fillPath()
    }
    ctx.setFillColor(rgb(FOLIAGE)); ctx.fill(CGRect(x: 0, y: 0, width: CGFloat(W), height: base))
    ctx.saveGState(); ctx.translateBy(x: 40, y: 90); pancakes(ctx, 500); ctx.restoreGState()
    let ns = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = ns
    let title = NSFont(name: "AvenirNextCondensed-Heavy", size: 80) ?? NSFont.boldSystemFont(ofSize: 70)
    let sub = NSFont(name: "AvenirNextCondensed-DemiBold", size: 34) ?? NSFont.boldSystemFont(ofSize: 30)
    NSAttributedString(string: "GRANITE STATE", attributes: [.font: title, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 560, y: 380))
    NSAttributedString(string: "EATS", attributes: [.font: title, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 560, y: 296))
    NSAttributedString(string: "ICE CREAM, LOBSTER & PANCAKES", attributes: [.font: sub, .foregroundColor: NSColor(srgbRed: 0.890, green: 0.663, blue: 0.231, alpha: 1)]).draw(at: NSPoint(x: 564, y: 246))
    NSGraphicsContext.restoreGraphicsState()
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}
og("docs/og.png")
