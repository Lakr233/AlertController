//
//  ActionContext.swift
//  AlertController
//
//  Created by 秋星桥 on 2/22/25.
//

import UIKit

open class ActionContext {
    public typealias ActionBlock = () -> Void
    public typealias DismissBlock = () -> Void
    public typealias DismissHandler = (@escaping DismissBlock) -> Void

    var actions = [Action]()
    var dismissHandler: DismissHandler?
    var userObject: Any?

    let spacing: CGFloat = 16

    init() {}

    func bind(to viewController: UIViewController) {
        dismissHandler = { [weak viewController, self] completionBlock in
            dismissHandler = nil
            viewController?.dismiss(animated: true) {
                completionBlock()
            }
        }
    }

    open func addAction(
        title: String,
        attribute: Action.Attribute = .normal,
        block: @escaping () -> Void
    ) {
        actions.append(.init(
            title: title,
            attribute: attribute,
            block: block
        ))
    }

    open func dispose(_ completion: @escaping () -> Void = {}) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        dismissHandler?(completion)
    }
}

public extension ActionContext {
    struct Action {
        let title: String
        let attribute: Attribute
        let block: ActionBlock
    }
}

public extension ActionContext.Action {
    enum Attribute {
        case normal
        case dangerous
    }
}
