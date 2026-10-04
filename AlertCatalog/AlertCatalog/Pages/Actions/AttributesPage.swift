//
//  AttributesPage.swift
//  AlertCatalog
//
//  The two action attributes, .normal and .accent, side by side and mixed.
//

import AlertController
import SwiftUI

struct AttributesPage: View {
    private static let code = """
    context.addAction(title: "Keep", attribute: .normal) { context.dispose() }
    context.addAction(title: "Delete", attribute: .accent) { context.dispose() }

    // There is no destructive attribute: an alert about a destructive
    // action draws it as the accent, in the accent color.
    AlertControllerConfiguration.accentColor = .systemRed
    """

    @State private var log = CatalogEventLog()

    var body: some View {
        CatalogPageScaffold(.attributes, code: Self.code, log: log, demos: [
            CatalogDemo("Normal and Accent", systemImage: "circle.lefthalf.filled") {
                present(
                    title: "Delete Photo?",
                    message: "This photo will be removed from all your devices.",
                    actions: [("Keep", .normal), ("Delete", .accent)],
                )
            },
            CatalogDemo("All Normal", systemImage: "circle") {
                present(
                    title: "All Normal",
                    message: "Nothing is marked .accent, so the last action is promoted.",
                    actions: [("First", .normal), ("Second", .normal), ("Third", .normal)],
                )
            },
            CatalogDemo("Two Accents", systemImage: "circle.fill") {
                present(
                    title: "Two Accents",
                    message: "Both filled actions are .accent; Return runs the first one.",
                    actions: [("Save", .accent), ("Save and Close", .accent), ("Cancel", .normal)],
                )
            },
        ]) {
            CatalogNote("ActionContext.Action.Attribute has only .normal and .accent. Both take their colors from AlertControllerConfiguration; change them on the Configuration page.", systemImage: "info.circle")
        }
    }

    private func present(
        title: String,
        message: String,
        actions: [(title: String, attribute: ActionContext.Action.Attribute)],
    ) {
        let log = log
        let alert = AlertViewController(title: title, message: message) { context in
            for action in actions {
                context.addAction(title: action.title, attribute: action.attribute) {
                    log.record("\(action.title) (\(action.attribute == .accent ? ".accent" : ".normal"))")
                    context.dispose()
                }
            }
        }
        AlertPresenter.present(alert)
    }
}
