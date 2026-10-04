//
//  AlertInputViewController.swift
//  AlertController
//
//  Created by 秋星桥 on 1/30/25.
//

import Foundation

open class AlertInputViewController: AlertViewController {
    public convenience init(
        title: String.LocalizationValue = "",
        message: String.LocalizationValue = "",
        placeholder: String.LocalizationValue,
        text: String,
        cancelButtonText: String.LocalizationValue = "Cancel",
        doneButtonText: String.LocalizationValue = "Done",
        onConfirm: @escaping @MainActor (String) -> Void
    ) {
        let confirm: @MainActor (ActionContext) -> Void = { context in
            context.dispose { onConfirm(context.userObject as! String) }
        }
        let controller = AlertInputContentController(
            title: String(localized: title),
            message: String(localized: message),
            originalText: text,
            placeholder: String(localized: placeholder),
            setupActions: { context in
                context.addAction(title: cancelButtonText) {
                    context.dispose()
                }
                context.addAction(title: doneButtonText, attribute: .accent) {
                    confirm(context)
                }
            },
            onSubmit: confirm
        )
        self.init(contentViewController: controller)
    }

    public required init(contentViewController: PlatformViewController) {
        super.init(contentViewController: contentViewController)
    }
}
