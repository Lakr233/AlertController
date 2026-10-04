//
//  ActionContext+Appearance.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

extension ActionContext.Action.Attribute {
    var foregroundColor: PlatformColor {
        switch self {
        case .accent:
            AlertControllerConfiguration.accentForegroundColor
        case .normal:
            AlertControllerConfiguration.accentColor
        }
    }

    var backgroundColor: PlatformColor {
        switch self {
        case .accent:
            AlertControllerConfiguration.accentColor
        case .normal:
            .clear
        }
    }

    var borderColor: PlatformColor {
        AlertControllerConfiguration.accentColor
    }

    var font: PlatformFont {
        switch self {
        case .accent:
            .alertSystemFont(forTextStyle: .body, weight: .semibold)
        case .normal:
            .alertSystemFont(forTextStyle: .body, weight: .regular)
        }
    }
}

extension PlatformFont {
    #if canImport(UIKit)
        /// Follows Dynamic Type; pair with `adjustsFontForContentSizeCategory`.
        static func alertSystemFont(
            forTextStyle textStyle: TextStyle,
            weight: Weight = .regular
        ) -> PlatformFont {
            .scaledSystemFont(forTextStyle: textStyle, weight: weight)
        }
    #elseif canImport(AppKit)
        /// System font at the macOS size of `textStyle`.
        static func alertSystemFont(
            forTextStyle textStyle: TextStyle,
            weight: Weight = .regular
        ) -> PlatformFont {
            let size = NSFont.preferredFont(forTextStyle: textStyle).pointSize
            return .systemFont(ofSize: size, weight: weight)
        }
    #endif
}
