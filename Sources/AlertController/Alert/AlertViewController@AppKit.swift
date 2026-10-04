//
//  AlertViewController@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit implementation lives in AlertViewController.swift.
#elseif canImport(AppKit)
    import AppKit

    open class AlertViewController: AlertBaseController {
        let contentViewController: NSViewController

        public required init(contentViewController: NSViewController) {
            self.contentViewController = contentViewController
            super.init(
                rootViewController: contentViewController,
                preferredWidth: AlertContentController.preferredWidth,
                preferredHeight: nil
            )

            var enableEscapeDismiss = false

            if let content = contentViewController as? AlertContentController {
                content.context.bind(to: self)
                enableEscapeDismiss = content.context.simpleDisposeRequested
            }

            shouldDismissWhenTappedAround = false
            shouldDismissWhenEscapeKeyPressed = enableEscapeDismiss
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override open func viewDidLoad() {
            super.viewDidLoad()
            contentView.layer?.cornerRadius = 20
            if let content = contentViewController as? AlertContentController {
                view.nextKeyView = content.keyViews.first
                contentView.setAccessibilityLabel(content.messageTitle)
            }
        }

        override var preferredInitialFirstResponder: NSView? {
            (contentViewController as? AlertContentController)?.initialFirstResponder
        }

        override func performDefaultAction() -> Bool {
            guard let content = contentViewController as? AlertContentController else {
                return false
            }
            return content.performAccentAction()
        }

        override func alertDidFinishDismissal() {
            super.alertDidFinishDismissal()
            guard let content = contentViewController as? AlertContentController else { return }
            content.context.releaseAfterDismissal()
        }
    }
#endif
