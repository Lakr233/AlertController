//
//  BasicAlertPage.swift
//  AlertCatalog
//
//  The everyday alert: a title, a message, Cancel and a confirming action.
//

import AlertController
import SwiftUI

struct BasicAlertPage: View {
    private static let code = """
    let alert = AlertViewController(
        title: "Hello World",
        message: "This is a sample alert message."
    ) { context in
        context.addAction(title: "Cancel") {
            context.dispose()
        }
        context.addAction(title: "Confirm", attribute: .accent) {
            context.dispose { print("Confirmed") }
        }
    }
    present(alert, animated: true)
    """

    @State private var log = CatalogEventLog()
    @State private var alertTitle = "Hello World"
    @State private var alertMessage = "This is a sample alert message."

    var body: some View {
        CatalogPageScaffold(.basicAlert, code: Self.code, log: log, demos: [
            CatalogDemo("Title and Message", systemImage: "exclamationmark.bubble") {
                present(title: alertTitle, message: alertMessage)
            },
            CatalogDemo("Title Only", systemImage: "rectangle.topthird.inset.filled") {
                present(title: alertTitle, message: "")
            },
            CatalogDemo("Message Only", systemImage: "text.alignleft") {
                present(title: "", message: alertMessage)
            },
        ]) {
            CatalogTextField("Title", text: $alertTitle)
            CatalogTextField("Message", text: $alertMessage, isMultiline: true)
            CatalogNote("An empty title or message is left out of the card, and the rest moves up.")
        }
    }

    private func present(title: String, message: String) {
        let log = log
        let alert = AlertViewController(title: .init(title), message: .init(message)) { context in
            context.addAction(title: "Cancel") {
                log.record("Cancel")
                context.dispose()
            }
            context.addAction(title: "Confirm", attribute: .accent) {
                log.record("Confirm")
                context.dispose { log.record("Confirm finished after the alert closed") }
            }
        }
        AlertPresenter.present(alert)
    }
}
