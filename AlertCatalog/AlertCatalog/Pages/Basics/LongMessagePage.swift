//
//  LongMessagePage.swift
//  AlertCatalog
//
//  Messages longer than the window: the title and message scroll inside the
//  card, and the actions stay below them.
//

import AlertController
import SwiftUI

struct LongMessagePage: View {
    private static let code = """
    let alert = AlertViewController(
        title: "License Agreement",
        message: agreementText // many paragraphs
    ) { context in
        context.addAction(title: "Decline") { context.dispose() }
        context.addAction(title: "Agree", attribute: .accent) { context.dispose() }
    }
    present(alert, animated: true)
    """

    private static let paragraph = "Magna dolor anim Lorem ullamco. Magna nostrud voluptate occaecat proident officia aliqua est minim aliquip qui ad est mollit dolor. Eu elit incididunt elit tempor sunt fugiat laborum ex eiusmod minim eu ex consectetur."

    @State private var log = CatalogEventLog()
    @State private var paragraphCount = 8

    var body: some View {
        CatalogPageScaffold(.longMessage, code: Self.code, log: log, demos: [
            CatalogDemo("Long Message", systemImage: "text.alignleft") {
                present(title: "License Agreement")
            },
            CatalogDemo("Long Title Too", systemImage: "textformat.size") {
                present(title: "Please Read the Following Terms Carefully Before You Continue With the Installation")
            },
        ]) {
            CatalogStepper("Paragraphs", value: $paragraphCount, in: 1 ... 20)
            CatalogNote("Make the window short to see the message scroll. The card never grows past the window, and the window is never resized for it.")
        }
    }

    private func present(title: String) {
        let log = log
        let message = (1 ... paragraphCount)
            .map { "\($0). \(Self.paragraph)" }
            .joined(separator: "\n\n")
        let alert = AlertViewController(title: .init(title), message: .init(message)) { context in
            context.addAction(title: "Decline") {
                log.record("Decline")
                context.dispose()
            }
            context.addAction(title: "Agree", attribute: .accent) {
                log.record("Agree")
                context.dispose()
            }
        }
        AlertPresenter.present(alert)
    }
}
