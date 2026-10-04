//
//  SingleActionPage.swift
//  AlertCatalog
//
//  An alert with one action, the shape of a notice the reader only has to
//  acknowledge.
//

import AlertController
import SwiftUI

struct SingleActionPage: View {
    private static let code = """
    let alert = AlertViewController(
        title: "Update Installed",
        message: "Version 2.0 is ready to use."
    ) { context in
        // The only action is promoted to .accent.
        context.addAction(title: "OK") {
            context.dispose()
        }
    }
    present(alert, animated: true)
    """

    @State private var log = CatalogEventLog()
    @State private var actionTitle = "OK"

    var body: some View {
        CatalogPageScaffold(.singleAction, code: Self.code, log: log, demos: [
            CatalogDemo("Acknowledge", systemImage: "checkmark.circle") {
                present(
                    title: "Update Installed",
                    message: "Version 2.0 is ready to use. Your documents and settings were kept.",
                )
            },
            CatalogDemo("Notice Without a Message", systemImage: "bell") {
                present(title: "Sync Complete", message: "")
            },
        ]) {
            CatalogTextField("Action title", text: $actionTitle)
            CatalogNote("The action is added with the .normal attribute; it is drawn filled because an alert with no accent action promotes its last one.")
        }
    }

    private func present(title: String, message: String) {
        let log = log
        let actionTitle = actionTitle.isEmpty ? "OK" : actionTitle
        let alert = AlertViewController(title: .init(title), message: .init(message)) { context in
            context.addAction(title: .init(actionTitle)) {
                log.record("\(actionTitle) on “\(title)”")
                context.dispose()
            }
        }
        AlertPresenter.present(alert)
    }
}
