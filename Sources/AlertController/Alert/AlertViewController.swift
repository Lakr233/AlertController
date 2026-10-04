//
//  Created by ktiays on 2024/11/27.
//  Copyright (c) 2024 ktiays. All rights reserved.
//

#if canImport(UIKit)
    import UIKit

    open class AlertViewController: AlertBaseController {
        let contentViewController: UIViewController

        public required init(contentViewController: UIViewController) {
            self.contentViewController = contentViewController
            super.init(
                rootViewController: contentViewController,
                preferredWidth: 350,
                preferredHeight: nil
            )

            var enableEscapeDismiss = false

            if let content = contentViewController as? AlertContentController {
                content.context.bind(to: self)
                enableEscapeDismiss = content.context.simpleDisposeRequested
            }

            transitioningDelegate = self
            modalPresentationStyle = .custom
            shouldDismissWhenTappedAround = false
            shouldDismissWhenEscapeKeyPressed = enableEscapeDismiss
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override open func viewDidLoad() {
            super.viewDidLoad()
            contentView.layer.cornerRadius = 20
        }

        override open func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            guard isBeingDismissed,
                  let content = contentViewController as? AlertContentController
            else { return }
            content.context.releaseAfterDismissal()
        }
    }
#endif
