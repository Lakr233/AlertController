//
//  ConfigurationPage.swift
//  AlertCatalog
//
//  AlertControllerConfiguration, edited live. The settings are global: they
//  apply to the next alert presented from any page, until reset.
//

import AlertController
import SwiftUI

struct ConfigurationPage: View {
    private static let code = """
    AlertControllerConfiguration.accentColor = .systemIndigo
    AlertControllerConfiguration.accentForegroundColor = .white
    AlertControllerConfiguration.backgroundColor = .systemBackground
    AlertControllerConfiguration.separatorColor = .separator

    // A UIImage on UIKit, an NSImage on AppKit; shown 64 points square.
    AlertControllerConfiguration.alertImage = UIImage(named: "AppBadge")
    """

    @Environment(AlertAppearance.self) private var appearance
    @State private var log = CatalogEventLog()

    var body: some View {
        @Bindable var appearance = appearance
        CatalogPageScaffold(.configuration, code: Self.code, log: log, demos: [
            CatalogDemo("Preview Alert", systemImage: "eye") {
                presentPreview()
            },
            CatalogDemo("Preview Input Alert", systemImage: "character.cursor.ibeam") {
                presentInputPreview()
            },
        ]) {
            ColorPicker("Accent color", selection: $appearance.accentColor, supportsOpacity: false)
            ColorPicker("Accent foreground color", selection: $appearance.accentForegroundColor, supportsOpacity: false)

            Toggle("Alert image", isOn: $appearance.showsImage)
            if appearance.showsImage {
                CatalogPicker("Symbol", selection: $appearance.imageSymbol, options: AlertAppearance.Symbol.allCases) { $0.title }
            }

            Toggle("Custom background color", isOn: $appearance.customizesBackground)
            if appearance.customizesBackground {
                ColorPicker("Background color", selection: $appearance.backgroundColor)
            }

            Toggle("Custom separator color", isOn: $appearance.customizesSeparator)
            if appearance.customizesSeparator {
                ColorPicker("Separator color", selection: $appearance.separatorColor)
            }

            Button("Reset to Defaults", role: .destructive) {
                appearance.reset()
                log.record("Configuration reset")
            }

            CatalogNote("The background color is drawn at half opacity over the blur material. The image is an SF Symbol rendered with ImageRenderer into a platform image.", systemImage: "info.circle")
        }
    }

    private func presentPreview() {
        let log = log
        let alert = AlertViewController(
            title: "Delete Draft?",
            message: "The draft and its attachments will be removed.",
        ) { context in
            context.addAction(title: "Keep") {
                log.record("Keep")
                context.dispose()
            }
            context.addAction(title: "Delete", attribute: .accent) {
                log.record("Delete")
                context.dispose()
            }
        }
        AlertPresenter.present(alert)
    }

    private func presentInputPreview() {
        let log = log
        let alert = AlertInputViewController(
            title: "New Folder",
            message: "The input field is tinted with the accent color.",
            placeholder: "Folder name",
            text: "Untitled Folder",
        ) { text in
            log.record("Created “\(text)”")
        }
        AlertPresenter.present(alert)
    }
}
