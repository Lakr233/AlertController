//
//  ProgressUpdatesPage.swift
//  AlertCatalog
//
//  AlertProgressIndicatorViewController while work runs: the message changes
//  through progressContext.purpose(message:), and the alert is dismissed
//  from code when the work is done.
//

import AlertController
import SwiftUI

struct ProgressUpdatesPage: View {
    private static let code = """
    let alert = AlertProgressIndicatorViewController(
        title: "Importing",
        message: "Preparing…"
    )
    present(alert, animated: true)

    Task { @MainActor in
        for file in files {
            alert.progressContext.purpose(message: "Copying \\(file.name)…")
            try await file.copy()
        }
        alert.dismiss(animated: true)
    }
    """

    private static let steps = [
        "Reading the library…",
        "Copying 24 photos…",
        "",
        "Generating thumbnails for the photos that were copied. This takes longer for large libraries.",
        "Cleaning up…",
    ]

    @State private var log = CatalogEventLog()
    @State private var stepInterval = 1.2
    @State private var currentStep: String?

    var body: some View {
        CatalogPageScaffold(.progressUpdates, code: Self.code, log: log, demos: [
            CatalogDemo("Run Import", systemImage: "hourglass") {
                runImport()
            },
            CatalogDemo("No Message", systemImage: "circle.dotted") {
                runSilent()
            },
        ]) {
            CatalogSlider("Time per step", value: $stepInterval, in: 0.4 ... 3, step: 0.2) {
                $0.formatted(.number.precision(.fractionLength(1))) + " s"
            }
            CatalogReadout("Current message", value: currentStep.map { $0.isEmpty ? "(empty)" : $0 } ?? "Idle")
            CatalogNote("An empty message hides the message line; the card shrinks and grows back with the next one.")
        }
    }

    private func runImport() {
        let log = log
        let alert = AlertProgressIndicatorViewController(title: "Importing", message: "Preparing…")
        AlertPresenter.present(alert)
        log.record("Started")
        let interval = stepInterval
        Task {
            for step in Self.steps {
                try? await Task.sleep(for: .seconds(interval))
                currentStep = step
                alert.progressContext.purpose(message: step)
            }
            try? await Task.sleep(for: .seconds(interval))
            alert.dismiss(animated: true) {
                log.record("Finished and dismissed")
            }
            currentStep = nil
        }
    }

    private func runSilent() {
        let log = log
        let alert = AlertProgressIndicatorViewController(title: "Please Wait")
        AlertPresenter.present(alert)
        let interval = stepInterval
        Task {
            try? await Task.sleep(for: .seconds(interval * 2))
            alert.dismiss(animated: true) {
                log.record("Dismissed after \(Int(interval * 2)) s")
            }
        }
    }
}
