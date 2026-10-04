//
//  ProgressMessagesPage.swift
//  AlertCatalog
//
//  Messages of every length through purpose(message:): one line, several
//  lines, several paragraphs, and back.
//

import AlertController
import SwiftUI

struct ProgressMessagesPage: View {
    private static let code = """
    let alert = AlertProgressIndicatorViewController(title: "Working")
    present(alert, animated: true)

    alert.progressContext.purpose(message: "One line.")
    alert.progressContext.purpose(message: \"\"\"
        A message with
        explicit line breaks,
        three lines long.
        \"\"\")
    """

    private static let messages = [
        "One line.",
        "A message with\nexplicit line breaks,\nthree lines long.",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.",
        "Short again.",
    ]

    private static let longMessage = (1 ... 9)
        .map { "Paragraph \($0). Irure id non ex cupidatat amet voluptate proident do duis anim proident qui nostrud. Pariatur aliqua quis ad adipisicing aute Lorem et magna consectetur." }
        .joined(separator: "\n\n")

    @State private var log = CatalogEventLog()
    @State private var customMessage = "Uploading “Holiday.mov”\n38 MB of 210 MB"

    var body: some View {
        CatalogPageScaffold(.progressMessages, code: Self.code, log: log, demos: [
            CatalogDemo("Cycle Message Lengths", systemImage: "text.bubble") {
                cycleMessages()
            },
            CatalogDemo("Very Long Message", systemImage: "scroll") {
                presentLongMessage()
            },
            CatalogDemo("Custom Message", systemImage: "pencil") {
                presentCustom()
            },
        ]) {
            CatalogTextField("Custom message", text: $customMessage, isMultiline: true)
            CatalogNote("A message taller than the window scrolls inside the card, the same as on a regular alert.")
        }
    }

    private func cycleMessages() {
        let log = log
        let alert = AlertProgressIndicatorViewController(title: "Working")
        AlertPresenter.present(alert)
        Task {
            for message in Self.messages {
                try? await Task.sleep(for: .seconds(1.5))
                alert.progressContext.purpose(message: message)
                log.record("\(message.components(separatedBy: .newlines).count) line(s) set, \(message.count) characters")
            }
            try? await Task.sleep(for: .seconds(1.5))
            alert.dismiss(animated: true)
        }
    }

    private func presentLongMessage() {
        let log = log
        let alert = AlertProgressIndicatorViewController(title: "Reading Terms", message: .init(Self.longMessage))
        AlertPresenter.present(alert)
        Task {
            try? await Task.sleep(for: .seconds(4))
            alert.dismiss(animated: true) {
                log.record("Long message dismissed after 4 s")
            }
        }
    }

    private func presentCustom() {
        let log = log
        let alert = AlertProgressIndicatorViewController(title: "Uploading")
        AlertPresenter.present(alert)
        let message = customMessage
        Task {
            try? await Task.sleep(for: .seconds(0.8))
            alert.progressContext.purpose(message: message)
            try? await Task.sleep(for: .seconds(3))
            alert.dismiss(animated: true) {
                log.record("Custom message dismissed")
            }
        }
    }
}
