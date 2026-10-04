//
//  ProgressContext.swift
//  AlertController
//
//  Created by 秋星桥 on 4/10/26.
//

import Foundation

open class ProgressContext: ActionContext {
    weak var contentController: AlertContentController?

    /// Latest message from `purpose(message:)`, applied when the view loads.
    var pendingMessage: String?

    @MainActor
    open func purpose(message: String) {
        assert(Thread.isMainThread)
        pendingMessage = message
        contentController?.updateMessage(message, animated: true)
    }
}
