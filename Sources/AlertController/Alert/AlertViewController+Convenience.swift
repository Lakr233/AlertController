//
//  AlertViewController+Convenience.swift
//  AlertController
//

import Foundation

public extension AlertViewController {
    convenience init(
        title: String.LocalizationValue = "",
        message: String.LocalizationValue = "",
        setupActions: @escaping @MainActor (ActionContext) -> Void
    ) {
        let controller = AlertContentController(
            title: String(localized: title),
            message: String(localized: message),
            setupActions: setupActions
        )
        self.init(contentViewController: controller)
    }
}
