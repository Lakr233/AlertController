//
//  ManyActionsPage.swift
//  AlertCatalog
//
//  Three or more actions, stacked vertically in the order they were added.
//

import AlertController
import SwiftUI

struct ManyActionsPage: View {
    private static let code = """
    let alert = AlertViewController(
        title: "Share Document",
        message: "Choose how to share “Quarterly Report”."
    ) { context in
        for title in ["Copy Link", "Send a Copy", "Export as PDF"] {
            context.addAction(title: title) {
                context.dispose { share(using: title) }
            }
        }
        context.addAction(title: "Cancel", attribute: .accent) {
            context.dispose()
        }
    }
    present(alert, animated: true)
    """

    private static let titles = [
        "Copy Link",
        "Send a Copy",
        "Export as PDF",
        "Duplicate",
        "Move to Folder",
        "Rename",
        "Print",
        "Add to Favorites",
    ]

    @State private var log = CatalogEventLog()
    @State private var actionCount = 4
    @State private var endsWithCancel = true

    var body: some View {
        CatalogPageScaffold(.manyActions, code: Self.code, log: log, demos: [
            CatalogDemo("Present Actions", systemImage: "list.bullet.rectangle") {
                present(count: actionCount)
            },
            CatalogDemo("Three Actions", systemImage: "3.circle") {
                present(count: 3)
            },
        ]) {
            CatalogStepper("Actions", value: $actionCount, in: 1 ... 9)
            Toggle("Last action is an accent Cancel", isOn: $endsWithCancel)
            CatalogNote("Exactly two actions may sit side by side; every other count stacks. With many actions the title and message scroll before the buttons do.")
        }
    }

    private func present(count: Int) {
        let log = log
        let endsWithCancel = endsWithCancel
        let titles = Array(Self.titles.prefix(endsWithCancel ? count - 1 : count))
        let alert = AlertViewController(
            title: "Share Document",
            message: "Choose how to share “Quarterly Report”.",
        ) { context in
            for title in titles {
                context.addAction(title: .init(title)) {
                    log.record(title)
                    context.dispose()
                }
            }
            guard endsWithCancel else { return }
            context.addAction(title: "Cancel", attribute: .accent) {
                log.record("Cancel")
                context.dispose()
            }
        }
        AlertPresenter.present(alert)
    }
}
