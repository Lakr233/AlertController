//
//  AccentPromotionPage.swift
//  AlertCatalog
//
//  Which action is drawn as the accent: the one marked .accent, or, when
//  none is, the last one added.
//

import AlertController
import SwiftUI

struct AccentPromotionPage: View {
    private static let code = """
    // No action is marked .accent, so "Install Now", the last one,
    // is drawn filled and, on macOS, runs when Return is pressed.
    context.addAction(title: "Later") { context.dispose() }
    context.addAction(title: "Remind Me Tonight") { context.dispose() }
    context.addAction(title: "Install Now") { context.dispose() }

    // Marking one action takes the accent away from the last.
    context.addAction(title: "Later", attribute: .accent) { context.dispose() }
    """

    /// Which of the three actions is marked `.accent`.
    enum Marked: String, CaseIterable, Identifiable {
        case none = "None"
        case first = "First"
        case middle = "Middle"
        case last = "Last"

        var id: Self {
            self
        }

        var index: Int? {
            switch self {
            case .none: nil
            case .first: 0
            case .middle: 1
            case .last: 2
            }
        }
    }

    private static let titles = ["Later", "Remind Me Tonight", "Install Now"]

    @State private var log = CatalogEventLog()
    @State private var marked = Marked.none
    @State private var usesTwoActions = false

    var body: some View {
        CatalogPageScaffold(.accentPromotion, code: Self.code, log: log, demos: [
            CatalogDemo("Present", systemImage: "star") {
                present(marked: marked)
            },
            CatalogDemo("Nothing Marked", systemImage: "star.slash") {
                present(marked: .none)
            },
            CatalogDemo("First Marked", systemImage: "star.fill") {
                present(marked: .first)
            },
        ]) {
            CatalogPicker("Action marked .accent", selection: $marked, options: Marked.allCases) { $0.rawValue }
            Toggle("Two actions instead of three", isOn: $usesTwoActions)
            CatalogNote("On native macOS, Return runs the accent action; with several accent actions it runs the first.")
        }
    }

    private func present(marked: Marked) {
        let log = log
        let titles = usesTwoActions ? [Self.titles[0], Self.titles[2]] : Self.titles
        let accentIndex = marked.index.map { min($0, titles.count - 1) }
        let alert = AlertViewController(
            title: "Software Update",
            message: "Version 2.0 is ready to install.",
        ) { context in
            for (index, title) in titles.enumerated() {
                let attribute: ActionContext.Action.Attribute = index == accentIndex ? .accent : .normal
                context.addAction(title: title, attribute: attribute) {
                    log.record(title)
                    context.dispose()
                }
            }
        }
        AlertPresenter.present(alert)
    }
}
