//
//  DisposePage.swift
//  AlertCatalog
//
//  How an alert goes away: context.dispose() from an action, with or without
//  a completion, and dismiss(animated:completion:) from code.
//

import AlertController
import SwiftUI

struct DisposePage: View {
    private static let code = """
    context.addAction(title: "Export", attribute: .accent) {
        // The completion runs on the main actor once the alert is gone,
        // so it can present the next alert.
        context.dispose {
            try? await Task.sleep(for: .seconds(1))
            present(doneAlert, animated: true)
        }
    }

    // From code, as with any presented controller:
    alert.dismiss(animated: true) { print("Gone") }
    """

    @State private var log = CatalogEventLog()

    var body: some View {
        CatalogPageScaffold(.dispose, code: Self.code, log: log, demos: [
            CatalogDemo("Dispose", systemImage: "xmark.circle") {
                presentDispose()
            },
            CatalogDemo("Dispose With Completion", systemImage: "checkmark.circle") {
                presentCompletion()
            },
            CatalogDemo("Chain a Second Alert", systemImage: "arrow.turn.down.right") {
                presentChain()
            },
            CatalogDemo("Dismiss From Code", systemImage: "timer") {
                presentTimed()
            },
        ]) {
            CatalogNote("A second dispose() on the same alert is ignored, and dispose() after the alert was closed some other way still runs its completion. On iOS, dispose plays a success haptic.")
        }
    }

    private func presentDispose() {
        let log = log
        let alert = AlertViewController(
            title: "Dispose",
            message: "This action calls context.dispose() with no completion.",
        ) { context in
            context.addAction(title: "Close") {
                log.record("Close tapped; the alert dismisses")
                context.dispose()
            }
        }
        AlertPresenter.present(alert)
    }

    private func presentCompletion() {
        let log = log
        let alert = AlertViewController(
            title: "Dispose With Completion",
            message: "The completion is recorded after the alert has finished closing.",
        ) { context in
            context.addAction(title: "Cancel") {
                context.dispose()
            }
            context.addAction(title: "Continue", attribute: .accent) {
                log.record("Continue tapped")
                context.dispose {
                    log.record("Completion ran after the dismissal")
                }
            }
        }
        AlertPresenter.present(alert)
    }

    private func presentChain() {
        let log = log
        let alert = AlertViewController(
            title: "Export Library",
            message: "Export 1,024 photos to a folder?",
        ) { context in
            context.addAction(title: "Cancel") {
                context.dispose()
            }
            context.addAction(title: "Export", attribute: .accent) {
                context.dispose {
                    log.record("First alert closed; exporting")
                    try? await Task.sleep(for: .seconds(1))
                    let done = AlertViewController(
                        title: "Export Finished",
                        message: "1,024 photos were exported.",
                    ) { context in
                        context.addAction(title: "OK") {
                            log.record("Second alert acknowledged")
                            context.dispose()
                        }
                    }
                    AlertPresenter.present(done)
                }
            }
        }
        AlertPresenter.present(alert)
    }

    private func presentTimed() {
        let log = log
        let alert = AlertViewController(
            title: "Closing by Itself",
            message: "This alert calls dismiss(animated:completion:) on itself after two seconds.",
        ) { context in
            context.addAction(title: "Close Now") {
                log.record("Closed early")
                context.dispose()
            }
        }
        AlertPresenter.present(alert)
        Task { [weak alert] in
            try? await Task.sleep(for: .seconds(2))
            // Closed early: nothing left to dismiss.
            guard let alert, alert.presentingViewController != nil else { return }
            alert.dismiss(animated: true) {
                log.record("dismiss(animated:) completion ran")
            }
        }
    }
}
