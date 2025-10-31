//
//  AlertViewController 2.swift
//  AlertController
//
//  Created by 秋星桥 on 1/30/25.
//

import UIKit

open class AlertInputViewController: AlertViewController {
    public convenience init(
        title: String.LocalizationValue = "",
        message: String.LocalizationValue = "",
        placeholder: String.LocalizationValue,
        text: String,
        cancelButtonText: String.LocalizationValue = "Cancel",
        doneButtonText: String.LocalizationValue = "Done",
        onConfirm: @escaping (String) -> Void
    ) {
        let controller = AlertInputContentController(
            title: String(localized: title),
            message: String(localized: message),
            originalText: text,
            placeholder: String(localized: placeholder)
        ) { context in
            context.addAction(title: cancelButtonText) {
                context.dispose()
            }
            context.addAction(title: doneButtonText, attribute: .accent) {
                context.dispose {
                    let text = context.userObject as! String
                    onConfirm(text)
                }
            }
        } onSubmit: { context in
            context.dispose {
                let text = context.userObject as! String
                onConfirm(text)
            }
        }
        self.init(contentViewController: controller)
    }

    @_disfavoredOverload
    public convenience init(
        title: String = "",
        message: String = "",
        placeholder: String,
        text: String,
        cancelButtonText: String = "Cancel",
        doneButtonText: String = "Done",
        onConfirm: @escaping (String) -> Void
    ) {
        self.init(
            title: String.LocalizationValue(title),
            message: String.LocalizationValue(message),
            placeholder: String.LocalizationValue(placeholder),
            text: text,
            cancelButtonText: String.LocalizationValue(cancelButtonText),
            doneButtonText: String.LocalizationValue(doneButtonText),
            onConfirm: onConfirm
        )
    }

    public required init(contentViewController: UIViewController) {
        super.init(contentViewController: contentViewController)
    }
}
