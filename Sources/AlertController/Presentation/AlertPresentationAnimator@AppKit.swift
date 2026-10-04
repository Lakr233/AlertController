//
//  AlertPresentationAnimator@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit uses AlertPresentationController and AlertTransitionAnimator.
#elseif canImport(AppKit)
    import AppKit

    /// Presents an `AlertBaseController` over a dimmed backdrop inside the
    /// presenting view controller's window, with a spring fade and scale.
    ///
    /// ```swift
    /// presentingViewController.present(alert, animator: AlertPresentationAnimator())
    /// ```
    public final class AlertPresentationAnimator: NSObject, NSViewControllerPresentationAnimator {
        public let animatesPresentation: Bool

        public init(animated: Bool = true) {
            animatesPresentation = animated
            super.init()
        }

        public func animatePresentation(
            of viewController: NSViewController,
            from fromViewController: NSViewController
        ) {
            let containerView = fromViewController.view.window?.contentView ?? fromViewController.view
            guard let alertController = viewController as? AlertBaseController else {
                assertionFailure("AlertPresentationAnimator presents AlertBaseController only.")
                viewController.view.frame = containerView.bounds
                viewController.view.autoresizingMask = [.width, .height]
                containerView.addSubview(viewController.view)
                return
            }
            // A SwiftUI window's content view is a hosting view whose hit
            // testing skips foreign subviews, so the overlay goes into the
            // window's frame view, right above the content view.
            if let contentView = fromViewController.view.window?.contentView,
               let frameView = contentView.superview
            {
                alertController.attachOverlay(to: frameView, above: contentView)
            } else {
                alertController.attachOverlay(to: containerView)
            }
            alertController.runPresentationAnimation(animated: animatesPresentation)
        }

        public func animateDismissal(
            of viewController: NSViewController,
            from _: NSViewController
        ) {
            guard let alertController = viewController as? AlertBaseController else {
                viewController.view.removeFromSuperview()
                return
            }
            alertController.runDismissalAnimation(animated: alertController.animatesNextDismissal)
        }
    }

    public extension NSViewController {
        /// Presents an alert inside this view controller's window. Mirrors
        /// `UIViewController.present(_:animated:completion:)`.
        func present(
            _ alert: AlertBaseController,
            animated: Bool,
            completion: (() -> Void)? = nil
        ) {
            alert.presentationCompletion = completion
            present(alert, animator: AlertPresentationAnimator(animated: animated))
        }
    }
#endif
