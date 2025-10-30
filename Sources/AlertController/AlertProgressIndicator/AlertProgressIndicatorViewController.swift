//
//  AlertProgressIndicatorViewController.swift
//  AlertController
//
//  Created by 秋星桥 on 1/30/25.
//

import UIKit

open class AlertProgressIndicatorViewController: AlertViewController {
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

    public required init(contentViewController: UIViewController) {
        super.init(contentViewController: contentViewController)
    }
}
