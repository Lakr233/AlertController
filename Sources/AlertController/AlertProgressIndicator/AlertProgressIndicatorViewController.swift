//
//  AlertProgressIndicatorViewController.swift
//  AlertController
//
//  Created by 秋星桥 on 1/30/25.
//

import UIKit

open class AlertProgressIndicatorViewController: AlertViewController {
    public convenience init(
        title: String = "",
        message: String = ""
    ) {
        let controller = AlertProgressIndicatorContentController(
            title: title,
            message: message
        ) { _ in }
        self.init(contentViewController: controller)
    }

    public required init(contentViewController: UIViewController) {
        super.init(contentViewController: contentViewController)
    }
}
