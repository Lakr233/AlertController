//
//  AlertProgressIndicatorViewController.swift
//  AlertController
//
//  Created by 秋星桥 on 1/30/25.
//

import Foundation

open class AlertProgressIndicatorViewController: AlertViewController {
    public var progressContext: ProgressContext {
        guard let contentViewController = contentViewController as? AlertProgressIndicatorContentController else {
            preconditionFailure("Expected AlertProgressIndicatorContentController")
        }
        return contentViewController.progressContext
    }

    public convenience init(
        title: String.LocalizationValue = "",
        message: String.LocalizationValue = ""
    ) {
        let controller = AlertProgressIndicatorContentController(
            title: String(localized: title),
            message: String(localized: message)
        ) { _ in }
        self.init(contentViewController: controller)
    }

    public required init(contentViewController: PlatformViewController) {
        super.init(contentViewController: contentViewController)
    }
}
