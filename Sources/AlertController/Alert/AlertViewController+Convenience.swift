//
//  AlertViewController+Convenience.swift
//  AlertController
//

import Foundation

public extension AlertViewController {
    convenience init(
        title: String.LocalizationValue = "",
        message: String.LocalizationValue = "",
        setupActions: @escaping (ActionContext) -> Void
    ) {
        let controller = AlertContentController(
            title: String(localized: title),
            message: String(localized: message),
            setupActions: setupActions
        )
        self.init(contentViewController: controller)
    }

    @_disfavoredOverload
    convenience init(
        title: String = "",
        message: String = "",
        setupActions: @escaping (ActionContext) -> Void
    ) {
        self.init(
            title: String.LocalizationValue(title),
            message: String.LocalizationValue(message),
            setupActions: setupActions
        )
    }
}
