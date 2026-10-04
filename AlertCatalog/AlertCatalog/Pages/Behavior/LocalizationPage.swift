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
    // String literals are String.LocalizationValue, looked up in the
    // app's Localizable.xcstrings.
    //
    // An interpolated literal passed straight in picks the String
    // overload, which bakes the number into the key. Type it as a
    // LocalizationValue so the interpolation becomes a format argument
    // and the key is "You have %lld unread messages."
    let message: String.LocalizationValue = "You have \\(count) unread messages."
    let alert = AlertViewController(
        title: "Welcome Back",
        message: message
    ) { context in
        context.addAction(title: "Later") { context.dispose() }
        context.addAction(title: "Read Now", attribute: .accent) { context.dispose() }
    }

    // A plain String is looked up as a key too.
    let key: String = "Welcome Back"
    AlertViewController(title: key, message: "") { _ in }
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
            CatalogNote("An interpolated literal passed straight to an initializer picks the plain String overload, so its key has the number baked in and is never found. Type it as String.LocalizationValue first.", systemImage: "exclamationmark.triangle")
            CatalogNote("The catalog ships English and Simplified Chinese. Pick the app's language in Settings on iOS, or launch the Mac app with -AppleLanguages \"(zh-Hans)\", to see the translations.", systemImage: "info.circle")
        }
    }

    private func presentLocalized() {
        let log = log
        let count = unreadCount
        // Typed explicitly: an interpolated literal would pick the String overload.
        let message: String.LocalizationValue = "You have \(count) unread messages."
        let alert = AlertViewController(
            title: "Welcome Back",
            message: message,
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
        let alert = AlertViewController(title: title, message: "") { context in
            context.addAction(title: action) {
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
