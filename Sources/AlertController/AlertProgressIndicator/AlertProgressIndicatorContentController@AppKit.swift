//
//  AlertProgressIndicatorContentController@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit implementation lives in AlertProgressIndicatorContentController.swift.
#elseif canImport(AppKit)
    import AppKit

    class AlertProgressIndicatorContentController: AlertContentController {
        let progressContext = ProgressContext()

        init(
            title: String = "",
            message: String = "",
            setupActions: @escaping @MainActor (ActionContext) -> Void
        ) {
            super.init(
                title: title,
                message: message,
                context: progressContext,
                setupActions: setupActions
            )

            customViews.append(HorizontalSeparator())
            customViews.append(ProgressIndicator())
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            progressContext.contentController = self
            if let pendingMessage = progressContext.pendingMessage {
                updateMessage(pendingMessage, animated: false)
            }
        }
    }

    class ProgressIndicator: NSView {
        private let indicator = NSProgressIndicator()

        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            indicator.style = .spinning
            indicator.controlSize = .small
            indicator.isIndeterminate = true
            indicator.isDisplayedWhenStopped = false
            indicator.translatesAutoresizingMaskIntoConstraints = false
            addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.topAnchor.constraint(equalTo: topAnchor, constant: 2),
                indicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
                indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            ])
            indicator.startAnimation(nil)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }
    }
#endif
