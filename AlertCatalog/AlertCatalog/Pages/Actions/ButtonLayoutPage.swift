//
//  ButtonLayoutPage.swift
//  AlertCatalog
//
//  Two actions sit side by side while both titles fit on one line at half
//  the card's width, and stack vertically as soon as either would wrap.
//

import AlertController
import SwiftUI

struct ButtonLayoutPage: View {
    private static let code = """
    // Short titles: side by side.
    context.addAction(title: "Cancel") { context.dispose() }
    context.addAction(title: "Delete", attribute: .accent) { context.dispose() }

    // A title that would wrap at half width: stacked.
    context.addAction(title: "Keep Editing in This Window") { context.dispose() }
    context.addAction(title: "Discard All Unsaved Changes", attribute: .accent) { context.dispose() }
    """

    @State private var log = CatalogEventLog()
    @State private var firstTitle = "Not Now"
    @State private var secondTitle = "Install Tonight"

    var body: some View {
        CatalogPageScaffold(.buttonLayout, code: Self.code, log: log, demos: [
            CatalogDemo("Short Titles", systemImage: "rectangle.split.2x1") {
                present(first: "Cancel", second: "Delete")
            },
            CatalogDemo("Long Titles", systemImage: "rectangle.split.1x2") {
                present(first: "Keep Editing in This Window", second: "Discard All Unsaved Changes")
            },
            CatalogDemo("One Long Title", systemImage: "rectangle.split.1x2") {
                present(first: "Cancel", second: "Delete Everything Permanently")
            },
            CatalogDemo("Custom Titles", systemImage: "pencil") {
                present(first: firstTitle, second: secondTitle)
            },
        ]) {
            CatalogTextField("First action", text: $firstTitle)
            CatalogTextField("Second action", text: $secondTitle)
            CatalogNote("The layout is decided when the alert is shown, from the titles measured in the button font; a larger text size on iOS stacks titles sooner.")
        }
    }

    private func present(first: String, second: String) {
        let log = log
        let alert = AlertViewController(
            title: "Unsaved Changes",
            message: "You have edits that are not saved yet.",
        ) { context in
            context.addAction(title: first) {
                log.record(first)
                context.dispose()
            }
            context.addAction(title: second, attribute: .accent) {
                log.record(second)
                context.dispose()
            }
        }
        AlertPresenter.present(alert)
    }
}
