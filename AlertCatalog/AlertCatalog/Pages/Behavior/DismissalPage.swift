//
//  DismissalPage.swift
//  AlertCatalog
//
//  Escape and taps outside the card. Both bounce the card unless the alert
//  allows them to dismiss it.
//

import AlertController
import SwiftUI

struct DismissalPage: View {
    private static let code = """
    let alert = AlertViewController(title: "Tip", message: "…") { context in
        // Escape (and the accessibility escape gesture) dismisses.
        context.allowSimpleDispose()
        context.addAction(title: "OK") { context.dispose() }
    }
    // A tap or click outside the card dismisses.
    alert.shouldDismissWhenTappedAround = true
    present(alert, animated: true)
    """

    @State private var log = CatalogEventLog()
    @State private var allowsEscape = true
    @State private var allowsTapAround = false

    var body: some View {
        CatalogPageScaffold(.dismissal, code: Self.code, log: log, demos: [
            CatalogDemo("Present", systemImage: "escape") {
                present(escape: allowsEscape, tapAround: allowsTapAround)
            },
            CatalogDemo("Neither Allowed", systemImage: "lock") {
                present(escape: false, tapAround: false)
            },
            CatalogDemo("Both Allowed", systemImage: "lock.open") {
                present(escape: true, tapAround: true)
            },
        ]) {
            Toggle("Escape dismisses (allowSimpleDispose())", isOn: $allowsEscape)
            Toggle("Tapping outside dismisses (shouldDismissWhenTappedAround)", isOn: $allowsTapAround)
            CatalogNote("Dismissing with Escape or a tap outside runs no action. On iOS, Escape needs a hardware keyboard; VoiceOver's escape gesture works the same way.")
        }
    }

    private func present(escape: Bool, tapAround: Bool) {
        let log = log
        let alert = AlertViewController(
            title: "Keyboard Shortcuts",
            message: message(escape: escape, tapAround: tapAround),
        ) { context in
            if escape {
                context.allowSimpleDispose()
            }
            context.addAction(title: "Got It") {
                log.record("Got It")
                context.dispose()
            }
        }
        alert.shouldDismissWhenTappedAround = tapAround
        AlertPresenter.present(alert)
        log.record("Presented: Escape \(escape ? "dismisses" : "bounces"), tap outside \(tapAround ? "dismisses" : "bounces")")
    }

    private func message(escape: Bool, tapAround: Bool) -> String {
        let escapeLine = escape ? "Press Escape to close this alert." : "Escape only bounces this alert."
        let tapLine = tapAround ? "A tap outside the card closes it." : "A tap outside the card only bounces it."
        return escapeLine + "\n" + tapLine
    }
}
