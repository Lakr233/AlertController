//
//  AlertViewController 2.swift
//  AlertController
//
//  Created by 秋星桥 on 1/30/25.
//

import UIKit

public class AlertInputViewController: AlertViewController {
    public convenience init(
        title: String = "",
        message: String = "",
        placeholder: String,
        text: String,
        cancelButtonText: String = NSLocalizedString(
            "Cancel",
            bundle: AlertControllerConfiguration.module,
            comment: ""
        ),
        doneButtonText: String = NSLocalizedString(
            "Done",
            bundle: AlertControllerConfiguration.module,
            comment: ""
        ),
        onConfirm: @escaping (String) -> Void
    ) {
        let controller = AlertInputContentController(
            title: title,
            message: message,
            originalText: text,
            placeholder: placeholder
        ) { context in
            context.addAction(title: cancelButtonText) {
                context.dispose()
            }
            context.addAction(title: doneButtonText, attribute: .dangerous) {
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

    required init(contentViewController: UIViewController) {
        super.init(contentViewController: contentViewController)
    }
}
