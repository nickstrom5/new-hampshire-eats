import Foundation
import CoreLocation
import UIKit

/// `-screenshot <name>` opens one screen with fixed state for App Store screenshots (scripts/capture-screenshots.sh).
/// Names: home, icecream, seafood, pancakes, honors, oldest, detail, map, saved, about.
enum ScreenshotMode {
    /// Debug builds only: an App Store build ignores the launch argument, so no one can reach seeded screens or fake locations.
    static var name: String? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screenshot"), i + 1 < args.count else { return nil }
        return args[i + 1]
        #else
        return nil
        #endif
    }
    static var isActive: Bool { name != nil }

    @MainActor
    static func apply(to model: AppModel) {
        guard let name, model.isLoaded else { return }
        model.filters = Filters()
        // Concord's Main Street, so "nearest" lists have distances without a permission prompt
        model.screenshotLocation = CLLocation(latitude: 43.2070, longitude: -71.5375)
        // by name and town, ignoring case, so a rebuild with a slightly different casing still finds the place; the hand-checked one first
        let pick = { (n: String, town: String?) -> Place? in
            let hits = model.places.filter { $0.name.caseInsensitiveCompare(n) == .orderedSame && (town == nil || $0.city == town) }
            return hits.first(where: \.handChecked) ?? hits.first
        }
        for p in [pick("Polly's Pancake Parlor", "Sugar Hill"), pick("Brown's Lobster Pound", "Seabrook"), pick("Red Arrow Diner", "Manchester")]
            .compactMap({ $0 }) where !model.isSaved(p) {
            model.toggleSaved(p)
        }
        let open = { (g: Guide) in model.tab = .guides; model.selectedGuide = g; model.guidesPath = [.guide(g)] }
        switch name {
        case "icecream": open(.iceCream)
        case "seafood":
            // Hampton Beach, among the Seacoast's lobster pounds
            model.screenshotLocation = CLLocation(latitude: 42.9110, longitude: -70.8120)
            open(.seafood)
        case "pancakes": open(.pancakes)
        case "honors": open(.honors)
        case "oldest": open(.oldest)
        case "detail":
            // Brown's Lobster Pound: a Seacoast lobster pound with its 1950 founding year and its note
            open(.seafood)
            if let p = pick("Brown's Lobster Pound", "Seabrook") ?? model.places.first {
                model.selectedPlace = p; model.guidesPath.append(.place(p))
            }
        case "map": model.tab = .map
        case "saved": model.tab = .saved
        case "about": model.tab = .about
        default: model.tab = .guides; model.selectedGuide = nil
        }
        // iPad shows the place column next to every list, so give each shot a place instead of "Pick a place": a different
        // honored or hand-checked one per shot.
        guard UIDevice.current.userInterfaceIdiom == .pad, model.selectedPlace == nil else { return }
        let place: Place? = switch name {
        case "home": pick("Polly's Pancake Parlor", "Sugar Hill")
        case "icecream": pick("Super Secret Ice Cream", "Bethlehem")
        case "seafood": pick("Brown's Lobster Pound", "Seabrook")
        case "pancakes": pick("Polly's Pancake Parlor", "Sugar Hill")
        case "map": pick("Red Arrow Diner", "Manchester")
        case "honors": pick("Puritan Backroom", "Manchester")
        case "oldest": pick("The Hancock Inn", "Hancock")
        case "saved": pick("Brown's Lobster Pound", "Seabrook")
        case "about": nil
        default: pick("Polly's Pancake Parlor", "Sugar Hill")
        }
        model.selectedPlace = place
    }
}
