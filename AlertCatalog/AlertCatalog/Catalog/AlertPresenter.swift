//
//  AlertPresenter.swift
//  AlertCatalog
//
//  The one place the catalog presents alerts from. SwiftUI pages have no view
//  controller of their own, so this finds the one to present from: the
//  topmost presented controller of the key window on UIKit, and the key
//  window's content view controller on AppKit.
//

import AlertController
import SwiftUI

enum AlertPresenter {
    /// Presents `alert` over the frontmost window, animated, the way an app
    /// calls `present(_:animated:)` from its own view controller.
    static func present(_ alert: AlertBaseController) {
        guard let presenter = presentingViewController() else {
            assertionFailure("There is no window to present the alert in.")
            return
        }
        presenter.present(alert, animated: true)
    }

    #if canImport(UIKit)
        /// The controller at the top of the key window's presentation chain.
        private static func presentingViewController() -> UIViewController? {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            let activeScenes = scenes.filter { $0.activationState == .foregroundActive }
            let windows = (activeScenes.isEmpty ? scenes : activeScenes).flatMap(\.windows)
            guard let window = windows.first(where: \.isKeyWindow) ?? windows.first else {
                return nil
            }
            var controller = window.rootViewController
            while let presented = controller?.presentedViewController, !presented.isBeingDismissed {
                controller = presented
            }
            return controller
        }
    #else
        /// The key window's content view controller; the alert covers that window.
        private static func presentingViewController() -> NSViewController? {
            let window = NSApp.keyWindow
                ?? NSApp.mainWindow
                ?? NSApp.windows.first { $0.isVisible && $0.contentViewController != nil }
            return window?.contentViewController
        }
    #endif
}
