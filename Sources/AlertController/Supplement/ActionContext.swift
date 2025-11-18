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

    // Set to true when the caller explicitly
    // opts in to simple ESC dismissal via
    // `allowSimpleDispose()`.
    var simpleDisposeRequested = false

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
        title: String.LocalizationValue,
        attribute: Action.Attribute = .normal,
        block: @escaping () -> Void
    ) {
        actions.append(.init(
            title: String(localized: title),
            attribute: attribute,
            block: block
        ))
    }

    @_disfavoredOverload
    open func addAction(
        title: String,
        attribute: Action.Attribute = .normal,
        block: @escaping () -> Void
    ) {
        addAction(
            title: String.LocalizationValue(title),
            attribute: attribute,
            block: block
        )
    }

    open func dispose(_ completion: @escaping @MainActor () async -> Void = {}) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        dismissHandler? {
            Task { @MainActor in
                await completion()
            }
        }
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
        case accent
    }
}

public extension ActionContext {
    func allowSimpleDispose() {
        simpleDisposeRequested = true
    }
}
