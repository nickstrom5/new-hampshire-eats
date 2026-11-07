import CoreLocation
import Observation
import UIKit

/// "Near me" sorting. Asks for when-in-use permission only when a list is sorted by distance or "My location" is tapped; the location never leaves the device.
@MainActor
@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private(set) var location: CLLocation?
    private(set) var status: CLAuthorizationStatus = .notDetermined
    /// no fix within 12 seconds, or Core Location reported an error
    private(set) var failed = false
    private var timeout: Task<Void, Never>?
    /// when the current request started: a fix from before it is a cached one (from launch, or before a drive) and doesn't count
    private var askedAt = Date.distantPast

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        status = manager.authorizationStatus
    }

    var isDenied: Bool { status == .denied || status == .restricted }

    /// Every place is in New Hampshire, so a reader elsewhere (an App Reviewer in California, say) gets told rather than an empty map.
    /// A coarse outline of the state (Idaho's lesson: a bounding box would count White River Junction, Brattleboro and Kittery),
    /// drawn a little outside the line so the river and bay shores count as inside.
    var isOutsideNewHampshire: Bool {
        guard let c = location?.coordinate else { return false }
        return !NewHampshireOutline.contains(c)
    }

    /// Once location is off for the app, iOS won't ask again; the app's page in Settings is the only way back.
    static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
    }

    func request() {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: locate()
        default: break
        }
    }

    private func locate() {
        failed = false
        let asked = Date()
        askedAt = asked
        manager.requestLocation()
        timeout?.cancel()
        timeout = Task { [weak self] in
            try? await Task.sleep(for: .seconds(12))
            guard let self, !Task.isCancelled else { return }
            if (self.location?.timestamp ?? .distantPast) < asked { self.failed = true }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ m: CLLocationManager) {
        let s = m.authorizationStatus
        Task { @MainActor in
            self.status = s
            if s == .authorizedWhenInUse || s == .authorizedAlways { self.locate() }
        }
    }

    nonisolated func locationManager(_ m: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let l = locations.last else { return }
        Task { @MainActor in
            // "My location" needs a fresh fix on every tap: a cached one from before the request would put you back where you were
            guard l.timestamp >= self.askedAt.addingTimeInterval(-2) else { return }
            self.location = l; self.failed = false; self.timeout?.cancel()
        }
    }

    nonisolated func locationManager(_ m: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in if self.location == nil { self.failed = true } }
    }
}

extension CLLocation {
    /// "0.4 mi", "12 mi", "1,012 mi" (an App Reviewer in California is a thousand miles out)
    func milesText(to other: CLLocation) -> String {
        let mi = distance(from: other) / 1609.344
        return (mi < 10 ? mi.formatted(.number.precision(.fractionLength(1))) : Int(mi.rounded()).formatted()) + " mi"
    }
}

/// A coarse New Hampshire outline (longitude, latitude), about 600 m outside the Overture land outline where the sea or a lake is, and
/// cut back to the line where Massachusetts, Vermont, Maine or Quebec is (buffer 0.006°, neighbours removed, simplify 0.006°; the
/// Isles of Shoals as their own ring). Salem, Nashua, Seabrook, Hanover, West Lebanon, Hinsdale, Portsmouth, Conway, Pittsburg and
/// Star Island are inside; Methuen, Tyngsborough, White River Junction, Brattleboro, Kittery and Fryeburg are not.
enum NewHampshireOutline {
    static let rings: [[(Double, Double)]] = [
        [(-70.61, 42.968), (-70.619, 42.971), (-70.617, 42.984), (-70.605, 42.979)],
        [(-70.697, 43.053), (-70.788, 42.937), (-70.811, 42.867), (-70.82, 42.872), (-70.848, 42.861), (-70.885, 42.883),
         (-70.915, 42.887), (-71.031, 42.86), (-71.045, 42.849), (-71.065, 42.807), (-71.133, 42.822), (-71.167, 42.809),
         (-71.187, 42.791), (-71.182, 42.738), (-71.246, 42.743), (-71.295, 42.698), (-72.458, 42.727), (-72.489, 42.772),
         (-72.515, 42.765), (-72.509, 42.78), (-72.541, 42.808), (-72.557, 42.854), (-72.552, 42.885), (-72.532, 42.896),
         (-72.524, 42.915), (-72.532, 42.954), (-72.473, 42.972), (-72.462, 42.982), (-72.463, 42.997), (-72.443, 43.007),
         (-72.462, 43.026), (-72.467, 43.052), (-72.435, 43.081), (-72.443, 43.102), (-72.432, 43.118), (-72.457, 43.147),
         (-72.443, 43.179), (-72.45, 43.193), (-72.439, 43.201), (-72.438, 43.252), (-72.416, 43.27), (-72.395, 43.313),
         (-72.41, 43.331), (-72.39, 43.356), (-72.413, 43.363), (-72.416, 43.377), (-72.403, 43.392), (-72.392, 43.466),
         (-72.382, 43.479), (-72.38, 43.493), (-72.399, 43.512), (-72.38, 43.54), (-72.38, 43.573), (-72.328, 43.601),
         (-72.334, 43.619), (-72.303, 43.669), (-72.299, 43.706), (-72.271, 43.733), (-72.235, 43.745), (-72.205, 43.771),
         (-72.205, 43.785), (-72.183, 43.809), (-72.184, 43.864), (-72.168, 43.869), (-72.172, 43.885), (-72.12, 43.92),
         (-72.118, 43.946), (-72.091, 43.965), (-72.114, 43.968), (-72.116, 43.994), (-72.104, 44.002), (-72.103, 44.014),
         (-72.09, 44.01), (-72.095, 44.022), (-72.082, 44.022), (-72.078, 44.043), (-72.062, 44.049), (-72.068, 44.057),
         (-72.048, 44.069), (-72.052, 44.076), (-72.031, 44.079), (-72.045, 44.087), (-72.033, 44.09), (-72.031, 44.101),
         (-72.048, 44.097), (-72.055, 44.111), (-72.033, 44.132), (-72.042, 44.137), (-72.038, 44.157), (-72.066, 44.19),
         (-72.047, 44.239), (-72.058, 44.27), (-72.068, 44.273), (-72.033, 44.302), (-72.03, 44.322), (-71.981, 44.337),
         (-71.934, 44.335), (-71.909, 44.348), (-71.871, 44.336), (-71.815, 44.354), (-71.814, 44.382), (-71.8, 44.384),
         (-71.795, 44.398), (-71.704, 44.413), (-71.662, 44.439), (-71.654, 44.459), (-71.639, 44.464), (-71.645, 44.475),
         (-71.599, 44.486), (-71.588, 44.506), (-71.576, 44.502), (-71.594, 44.521), (-71.571, 44.538), (-71.597, 44.559),
         (-71.56, 44.564), (-71.547, 44.571), (-71.554, 44.579), (-71.553, 44.584), (-71.546, 44.577), (-71.535, 44.588),
         (-71.562, 44.602), (-71.547, 44.63), (-71.563, 44.637), (-71.563, 44.653), (-71.577, 44.651), (-71.588, 44.66),
         (-71.581, 44.674), (-71.597, 44.678), (-71.594, 44.696), (-71.617, 44.729), (-71.626, 44.729), (-71.632, 44.751),
         (-71.573, 44.791), (-71.568, 44.807), (-71.577, 44.815), (-71.551, 44.837), (-71.55, 44.862), (-71.512, 44.884),
         (-71.514, 44.894), (-71.495, 44.905), (-71.522, 44.94), (-71.515, 44.942), (-71.516, 44.964), (-71.524, 44.965),
         (-71.518, 44.968), (-71.541, 44.985), (-71.525, 45.002), (-71.505, 45.008), (-71.488, 45.0), (-71.465, 45.013),
         (-71.5, 45.014), (-71.49, 45.043), (-71.506, 45.048), (-71.497, 45.056), (-71.498, 45.07), (-71.468, 45.083),
         (-71.448, 45.112), (-71.428, 45.123), (-71.437, 45.142), (-71.397, 45.203), (-71.403, 45.216), (-71.442, 45.238),
         (-71.421, 45.232), (-71.402, 45.242), (-71.384, 45.233), (-71.356, 45.254), (-71.36, 45.27), (-71.336, 45.272),
         (-71.296, 45.299), (-71.265, 45.293), (-71.26, 45.272), (-71.231, 45.249), (-71.197, 45.254), (-71.18, 45.239),
         (-71.162, 45.25), (-71.148, 45.239), (-71.124, 45.255), (-71.105, 45.295), (-71.085, 45.305), (-71.035, 44.71),
         (-70.973, 43.57), (-70.951, 43.551), (-70.964, 43.539), (-70.955, 43.51), (-70.977, 43.479), (-70.962, 43.469),
         (-70.961, 43.439), (-70.987, 43.414), (-70.989, 43.389), (-70.973, 43.348), (-70.956, 43.334), (-70.937, 43.337),
         (-70.931, 43.336), (-70.897, 43.298), (-70.906, 43.291), (-70.81, 43.226), (-70.829, 43.188), (-70.824, 43.174),
         (-70.834, 43.146), (-70.827, 43.127), (-70.757, 43.08), (-70.707, 43.075), (-70.703, 43.052)]]

    static func contains(_ c: CLLocationCoordinate2D) -> Bool { rings.contains { contains(c, ring: $0) } }

    /// Ray casting: a point is inside when a ray east of it crosses the outline an odd number of times.
    static func contains(_ c: CLLocationCoordinate2D, ring: [(Double, Double)]) -> Bool {
        var inside = false
        var j = ring.count - 1
        for i in 0..<ring.count {
            let (xi, yi) = ring[i], (xj, yj) = ring[j]
            if (yi > c.latitude) != (yj > c.latitude) && c.longitude < (xj - xi) * (c.latitude - yi) / (yj - yi) + xi { inside.toggle() }
            j = i
        }
        return inside
    }
}
