//
//  InputAlertPage.swift
//  AlertCatalog
//
//  AlertInputViewController: one text field, prefilled or empty, whose text
//  comes back through onConfirm when Done is tapped or Return is pressed.
//

import AlertController
import SwiftUI

struct InputAlertPage: View {
    private static let code = """
    let alert = AlertInputViewController(
        title: "Rename Document",
        message: "Enter a new name for the document.",
        placeholder: "Document name",
        text: "Quarterly Report"
    ) { text in
        document.name = text
    }
    present(alert, animated: true)
    """

    @State private var log = CatalogEventLog()
    @State private var prefill = "Quarterly Report"
    @State private var placeholder = "Document name"
    @State private var confirmedText: String?

    var body: some View {
        CatalogPageScaffold(.inputAlert, code: Self.code, log: log, demos: [
            CatalogDemo("Prefilled", systemImage: "character.cursor.ibeam") {
                present(text: prefill)
            },
            CatalogDemo("Empty", systemImage: "rectangle.and.pencil.and.ellipsis") {
                present(text: "")
            },
            CatalogDemo("Custom Button Titles", systemImage: "pencil.and.list.clipboard") {
                presentCustomButtons()
            },
        ]) {
            CatalogReadout("Confirmed text", value: confirmedText.map { "“\($0)”" } ?? "None yet")
            CatalogTextField("Prefilled text", text: $prefill)
            CatalogTextField("Placeholder", text: $placeholder)
            CatalogNote("Cancel closes the alert without calling onConfirm. The field takes focus when the alert appears; on macOS its text is selected so typing replaces it.")
        }
    }

    private func present(text: String) {
        let alert = AlertInputViewController(
            title: "Rename Document",
            message: "Enter a new name for the document.",
            placeholder: placeholder,
            text: text,
        ) { text in
            confirm(text)
        }
        AlertPresenter.present(alert)
    }

    private func presentCustomButtons() {
        let alert = AlertInputViewController(
            title: "Join Network",
            message: "Enter the password for “Studio Wi-Fi”.",
            placeholder: "Password",
            text: "",
            cancelButtonText: "Not Now",
            doneButtonText: "Join",
        ) { text in
            confirm(text)
        }
        AlertPresenter.present(alert)
    }

    private func confirm(_ text: String) {
        confirmedText = text
        log.record("onConfirm: “\(text)”")
    }
}
