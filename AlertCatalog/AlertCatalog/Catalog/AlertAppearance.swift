//
//  AlertAppearance.swift
//  AlertCatalog
//
//  The catalog's copy of AlertControllerConfiguration. The configuration is
//  global, so every change made here is written through at once and applies
//  to the next alert any page presents.
//

// AlertControllerConfiguration predates Swift 6: its settings are plain static
// vars, which the catalog only touches from the main actor.
@preconcurrency import AlertController
import SwiftUI

@Observable
final class AlertAppearance {
    /// The SF Symbols the configuration page offers for the alert image.
    enum Symbol: String, CaseIterable, Identifiable {
        case bell = "bell.badge.fill"
        case warning = "exclamationmark.triangle.fill"
        case trash = "trash.fill"
        case lock = "lock.fill"
        case sparkles

        var id: Self {
            self
        }

        var title: String {
            switch self {
            case .bell: "Bell"
            case .warning: "Warning"
            case .trash: "Trash"
            case .lock: "Lock"
            case .sparkles: "Sparkles"
            }
        }
    }

    var accentColor: Color {
        didSet { apply() }
    }

    var accentForegroundColor: Color {
        didSet { apply() }
    }

    var showsImage = false {
        didSet { apply() }
    }

    var imageSymbol = Symbol.bell {
        didSet { apply() }
    }

    var customizesBackground = false {
        didSet { apply() }
    }

    var backgroundColor: Color {
        didSet { apply() }
    }

    var customizesSeparator = false {
        didSet { apply() }
    }

    var separatorColor: Color {
        didSet { apply() }
    }

    /// The configuration as the package ships it, captured before any change.
    @ObservationIgnored private let defaults: Defaults

    init() {
        let defaults = Defaults()
        self.defaults = defaults
        accentColor = Color(platformColor: defaults.accentColor)
        accentForegroundColor = Color(platformColor: defaults.accentForegroundColor)
        backgroundColor = Color(platformColor: defaults.backgroundColor)
        separatorColor = Color(platformColor: defaults.separatorColor)
    }

    /// Puts every setting back to the package's defaults.
    func reset() {
        accentColor = Color(platformColor: defaults.accentColor)
        accentForegroundColor = Color(platformColor: defaults.accentForegroundColor)
        showsImage = false
        imageSymbol = .bell
        customizesBackground = false
        backgroundColor = Color(platformColor: defaults.backgroundColor)
        customizesSeparator = false
        separatorColor = Color(platformColor: defaults.separatorColor)
    }

    /// Writes the settings to `AlertControllerConfiguration`. Colors left at their
    /// defaults keep the package's dynamic colors, which follow dark mode.
    private func apply() {
        AlertControllerConfiguration.accentColor = accentColor.platformColor
        AlertControllerConfiguration.accentForegroundColor = accentForegroundColor.platformColor
        AlertControllerConfiguration.backgroundColor = customizesBackground
            ? backgroundColor.platformColor
            : defaults.backgroundColor
        AlertControllerConfiguration.separatorColor = customizesSeparator
            ? separatorColor.platformColor
            : defaults.separatorColor
        AlertControllerConfiguration.alertImage = showsImage
            ? AlertSymbolImage.render(imageSymbol.rawValue, background: accentColor, foreground: accentForegroundColor)
            : nil
    }
}

private extension AlertAppearance {
    struct Defaults {
        let accentColor = AlertControllerConfiguration.accentColor
        let accentForegroundColor = AlertControllerConfiguration.accentForegroundColor
        let backgroundColor = AlertControllerConfiguration.backgroundColor
        let separatorColor = AlertControllerConfiguration.separatorColor
    }
}

/// Draws an SF Symbol on a colored tile and returns it as a `UIImage` or an
/// `NSImage`, the type `AlertControllerConfiguration.alertImage` takes.
enum AlertSymbolImage {
    static let size: CGFloat = 64

    static func render(_ systemName: String, background: Color, foreground: Color) -> PlatformImage? {
        let tile = ZStack {
            Rectangle()
                .fill(background.gradient)
            Image(systemName: systemName)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundStyle(foreground)
        }
        .frame(width: size, height: size)

        let renderer = ImageRenderer(content: tile)
        renderer.scale = 3
        #if canImport(UIKit)
            return renderer.uiImage
        #else
            return renderer.nsImage
        #endif
    }
}
