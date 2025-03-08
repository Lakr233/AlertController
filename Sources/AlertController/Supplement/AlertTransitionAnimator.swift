//
//  Created by ktiays on 2024/11/28.
//  Copyright (c) 2024 ktiays. All rights reserved.
//

import UIKit

public final class AlertTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool

    public init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }

    public func transitionDuration(using _: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        0.24
    }

    public func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let alertController = if isPresenting {
            transitionContext.viewController(forKey: .to)
        } else {
            transitionContext.viewController(forKey: .from)
        }
        guard let alertController = alertController as? AlertBaseController else {
            assertionFailure("The view controller must be an instance of AlertContents.")
            transitionContext.completeTransition(false)
            return
        }

        let dimmingView = alertController.dimmingView
        let alertView = alertController.contentView

        if isPresenting {
            dimmingView.alpha = 0
            alertView.alpha = 0
            alertView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.8
        ) { [self] in
            if isPresenting {
                dimmingView.alpha = 0.25
                alertView.alpha = 1
                alertView.transform = .identity
            } else {
                dimmingView.alpha = 0
                alertView.alpha = 0
                alertView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        } completion: {
            transitionContext.completeTransition($0)
        }
    }
}
