//
//  LocalizationPage.swift
//  AlertCatalog
//
//  Every title, message and action title is a String.LocalizationValue,
//  looked up in the app's string catalog. The input alert's default Cancel
//  and Done come from the package's own translations.
//

import AlertController
import SwiftUI

struct LocalizationPage: View {
    private static let code = """
    // Titles, messages and action titles are String.LocalizationValue,
    // looked up in the app's Localizable.xcstrings. An interpolated
    // literal becomes a format argument, so the key here is
    // "You have %lld unread messages."
    let alert = AlertViewController(
        title: "Welcome Back",
        message: "You have \\(count) unread messages."
    ) { context in
        context.addAction(title: "Later") { context.dispose() }
        context.addAction(title: "Read Now", attribute: .accent) { context.dispose() }
    }

    // A String made at run time is wrapped explicitly and looked up as a
    // key; text with no translation shows as it is.
    let key: String = "Welcome Back"
    AlertViewController(title: .init(key), message: "") { _ in }
    """

    @State private var log = CatalogEventLog()
    @State private var unreadCount = 3

    private var languageDescription: String {
        let language = Bundle.main.preferredLocalizations.first ?? "en"
        return Locale.current.localizedString(forIdentifier: language).map { "\($0) (\(language))" } ?? language
    }

    var body: some View {
        CatalogPageScaffold(.localization, code: Self.code, log: log, demos: [
            CatalogDemo("Localized Alert", systemImage: "globe") {
                presentLocalized()
            },
            CatalogDemo("Plain String Keys", systemImage: "character.book.closed") {
                presentPlainStrings()
            },
            CatalogDemo("Input Alert Defaults", systemImage: "character.cursor.ibeam") {
                presentInput()
            },
            CatalogDemo("Progress", systemImage: "hourglass") {
                presentProgress()
            },
        ]) {
            CatalogReadout("App language", value: languageDescription)
            CatalogStepper("Unread messages", value: $unreadCount, in: 0 ... 99)
            CatalogNote(
                "An interpolated literal becomes a format argument, so its translation is found whatever the count. A String made at run time is wrapped with .init(_:) and looked up as a key.",
                systemImage: "info.circle"
            )
            CatalogNote(
                "The catalog ships English and Simplified Chinese. Pick the app's language in Settings on iOS, or launch the Mac app with -AppleLanguages \"(zh-Hans)\", to see the translations.",
                systemImage: "info.circle"
            )
        }
    }

    private func presentLocalized() {
        let log = log
        let count = unreadCount
        let alert = AlertViewController(
            title: "Welcome Back",
            message: "You have \(count) unread messages.",
        ) { context in
            context.addAction(title: "Later") {
                log.record("Later")
                context.dispose()
            }
            context.addAction(title: "Read Now", attribute: .accent) {
                log.record("Read Now")
                context.dispose()
            }
        }
        AlertPresenter.present(alert)
    }

    private func presentPlainStrings() {
        let log = log
        let title = "Welcome Back"
        let action = "Read Now"
        let alert = AlertViewController(title: .init(title), message: "") { context in
            context.addAction(title: .init(action)) {
                log.record("Plain String keys: \(action)")
                context.dispose()
            }
        }
        AlertPresenter.present(alert)
    }

    private func presentInput() {
        let log = log
        let alert = AlertInputViewController(
            title: "What Should We Call You?",
            message: "Cancel and Done are translated by AlertController itself.",
            placeholder: "Your name",
            text: "",
        ) { text in
            log.record("Name: “\(text)”")
        }
        AlertPresenter.present(alert)
    }

    private func presentProgress() {
        let alert = AlertProgressIndicatorViewController(title: "Syncing", message: "Checking for changes…")
        AlertPresenter.present(alert)
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            alert.progressContext.purpose(message: String(localized: "Downloading changes…"))
            try? await Task.sleep(for: .seconds(1.5))
            alert.dismiss(animated: true)
        }
    }
}
