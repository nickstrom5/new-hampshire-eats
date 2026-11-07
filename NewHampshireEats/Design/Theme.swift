import SwiftUI
import UIKit
import CoreText

/// New Hampshire palette, a landscape one (provisional, 2026-11-06; Nick decides, playbook/05-naming.md), light only, from
/// state-prompts/NEW_HAMPSHIRE_PROMPT.md (no major-league team plays here, and Maine's prompt already takes Red Sox navy and red):
/// granite #3E4A52 (9.2:1 on white) for titles, tint and accents; foliage orange #B5471B (white on it 5.4:1) for the hand-checked guide
/// cards; lilac #6A4C93 (the state flower; white on it 6.9:1) for honors chips; autumn gold #E3A93B only as a pin and card fill under
/// granite text; birch white #F6F4EF pages. The names `green`/`gold` are kept from Wisconsin Eats so the shared views read the same;
/// here `green` is granite and `gold` is foliage orange.
enum Theme {
    static let green = Color(hex: 0x3E4A52)      // granite: titles, tint, primary text accents
    static let green2 = Color(hex: 0x5E6A71)
    static let gold = Color(hex: 0xB5471B)       // foliage orange: card fills under white text
    static let goldSoft = Color(hex: 0xF6DDD2)   // soft foliage
    static let lime = Color(hex: 0xE3A93B)       // autumn gold, fills only (hand-checked pins, the title shadow), under granite text
    static let limeSoft = Color(hex: 0xF9EBCB)
    static let sand = Color(hex: 0xF6F4EF)       // the Home background, birch white
    static let red = Color(hex: 0x6A4C93)        // honors chips, lilac
    static let sandstone = Color(hex: 0x8E3514)  // a darker foliage accent (7.6:1 on white)
    static let teal = Color(hex: 0x1F4D3A)       // spruce accent (10.0:1 on white)
    static let ink = Color(hex: 0x1A1A1A)
    static let ink2 = Color(hex: 0x2E3440)
    static let muted = Color(hex: 0x5B6270)
    static let surface = Color.white
    static let surface2 = Color(hex: 0xF1EEE6)
    static let surface3 = Color(hex: 0xE4DFD3)
    static let rule = Color(hex: 0xE4DFD3)
    static let rule2 = Color(hex: 0xCCC4B3)
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

/// A small uppercase label: "STONE CRAB", "1 MICHELIN STAR".
struct Chip: View {
    enum Style { case gold, green, red, plain, dashed }
    let text: String
    var style: Style = .plain

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(0.4)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .foregroundStyle(style == .green || style == .red ? Color.white : style == .dashed ? Theme.muted : style == .gold ? Theme.ink : Theme.green)
            .background {
                RoundedRectangle(cornerRadius: 5).fill(style == .gold ? Theme.goldSoft : style == .green ? Theme.green : style == .red ? Theme.red
                                                       : style == .dashed ? .clear : Theme.surface2)
            }
            .overlay {
                if style == .dashed { RoundedRectangle(cornerRadius: 5).strokeBorder(Theme.rule2, style: StrokeStyle(lineWidth: 1, dash: [3, 2])) }
            }
            .accessibilityLabel(text)
    }
}

/// Granite State Eats' lettering: the system face drawn compressed and heavy for titles and guide names (like a show poster), and the
/// system monospaced face for numbers, dates and small labels. No bundled fonts.
struct DisplayFont: ViewModifier {
    let size: CGFloat
    var weight: Font.Weight = .black
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content.font(.system(size: size * min(scale, 1.6), weight: weight).width(.compressed))
    }
}

/// Numbers, dates and small labels in the system monospaced face, scaled like DisplayFont.
struct MonoFont: ViewModifier {
    let size: CGFloat
    var weight: Font.Weight = .semibold
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content.font(.system(size: size * min(scale, 1.6), weight: weight, design: .monospaced))
    }
}

extension View {
    func displayFont(_ size: CGFloat, weight: Font.Weight = .black) -> some View {
        modifier(DisplayFont(size: size, weight: weight))
    }

    func monoFont(_ size: CGFloat, weight: Font.Weight = .semibold) -> some View {
        modifier(MonoFont(size: size, weight: weight))
    }
}

/// The header band: the White Mountains' Presidential Range in two layers, the farther paler, over a foliage baseline. No state seal and
/// no Old Man of the Mountain (the state's route-sign emblem).
struct Stripes: View {
    var height: CGFloat = 6

    /// (x, rise) for each ridge, back to front: 0 is the baseline, 1 the band's top; the front ridge peaks at Mount Washington
    static let ridges: [[(CGFloat, CGFloat)]] = [
        [(0, 0.55), (0.10, 0.70), (0.22, 0.58), (0.35, 0.80), (0.50, 0.66), (0.66, 0.84), (0.80, 0.62), (0.92, 0.74), (1, 0.60)],
        [(0, 0.20), (0.14, 0.42), (0.28, 0.30), (0.40, 0.62), (0.47, 0.75), (0.52, 1.0), (0.58, 0.78), (0.66, 0.52), (0.80, 0.36),
         (0.92, 0.46), (1, 0.28)]]

    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height, base = h * 0.78
            for (i, ridge) in Self.ridges.enumerated() {
                var p = Path()
                p.move(to: CGPoint(x: 0, y: base))
                for (x, rise) in ridge { p.addLine(to: CGPoint(x: x * w, y: base - base * rise)) }
                p.addLine(to: CGPoint(x: w, y: base)); p.closeSubpath()
                ctx.fill(p, with: .color(Theme.green.opacity([0.45, 1.0][i])))
            }
            // the foliage baseline last
            ctx.fill(Path(CGRect(x: 0, y: base, width: w, height: h - base)), with: .color(Theme.gold))
        }
        .frame(height: height * 2.4)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .accessibilityHidden(true)
    }
}

extension View {
    /// An inline navigation title in the display type. UINavigationBar.appearance() didn't reach every SwiftUI bar on iOS 27
    /// (the Map title went from compressed blue to plain black after a push and pop; place titles were always plain), so the
    /// title is our own view in the bar. The navigation title is still set, for the back button and VoiceOver.
    func inlineTitle(_ title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title).displayFont(19, weight: .heavy).foregroundStyle(Theme.green)
                        .lineLimit(1).minimumScaleFactor(0.7)
                        .accessibilityAddTraits(.isHeader)
                }
            }
    }
}
