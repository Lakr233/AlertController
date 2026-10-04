//
//  ProgressContext.swift
//  AlertController
//
//  Created by 秋星桥 on 4/10/26.
//

import UIKit

open class ProgressContext: ActionContext {
    weak var messageLabel: UILabel?
    weak var contentController: AlertContentController?

    /// Latest message from `purpose(message:)`, applied when the view loads.
    var pendingMessage: String?

    @MainActor
    open func purpose(message: String) {
        assert(Thread.isMainThread)
        pendingMessage = message
        if let contentController {
            contentController.updateMessage(message, animated: true)
            return
        }
        messageLabel?.isHidden = message.isEmpty
        messageLabel?.text = message
    }
}
