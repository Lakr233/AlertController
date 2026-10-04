//
//  PlatformColor+Catalog.swift
//  AlertCatalog
//
//  Converts between SwiftUI colors and the platform colors
//  AlertControllerConfiguration stores.
//

import AlertController
import SwiftUI

extension Color {
    /// The SwiftUI color for a `UIColor` or an `NSColor`.
    init(platformColor: PlatformColor) {
        #if canImport(UIKit)
            self.init(uiColor: platformColor)
        #else
            self.init(nsColor: platformColor)
        #endif
    }

    /// This color as a `UIColor` or an `NSColor`.
    var platformColor: PlatformColor {
        PlatformColor(self)
    }
}
