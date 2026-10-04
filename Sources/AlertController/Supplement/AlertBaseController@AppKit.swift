//
//  AlertBaseController@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit implementation lives in AlertBaseController.swift.
#elseif canImport(AppKit)
    import AppKit

    public typealias AlertControllerObject = NSViewController

    /// Hosts alert content in a card over a dimmed backdrop inside the
    /// presenting window. Present it with `present(_:animated:completion:)`
    /// on any `NSViewController`, or with `present(_:animator:)` and an
    /// `AlertPresentationAnimator`.
    open class AlertBaseController: AlertControllerObject {
        public let dimmingView: NSView = AlertDimmingView()
        public let contentView: NSView = .init()
        public let contentLayoutGuide = NSLayoutGuide()

        public let contentBackgroundView: NSVisualEffectView = {
            let view = NSVisualEffectView()
            view.material = .popover
            view.blendingMode = .withinWindow
            view.state = .active
            return view
        }()

        open var shouldDismissWhenTappedAround = false
        open var shouldDismissWhenEscapeKeyPressed = false
        private let preferredWidth: CGFloat?
        private let preferredHeight: CGFloat?

        enum TransitionState {
            case idle
            case presenting
            case presented
            case dismissing
        }

        private(set) var transitionState = TransitionState.idle
        /// Set while the overlay sits in a window, attached by `AlertPresentationAnimator`.
        private(set) var isAttached = false
        /// Whether the next dismissal animates; consumed by the animator.
        var animatesNextDismissal = true
        var presentationCompletion: (() -> Void)?
        private var pendingDismissal: Bool?
        private var dismissalCompletions = [() -> Void]()
        private weak var previousFirstResponder: NSResponder?
        private var keyEventMonitor: Any?

        public init() {
            preferredWidth = nil
            preferredHeight = nil
            super.init(nibName: nil, bundle: nil)
        }

        public init(
            rootViewController: NSViewController,
            preferredWidth: CGFloat? = 550,
            preferredHeight: CGFloat? = 550
        ) {
            self.preferredWidth = preferredWidth
            self.preferredHeight = preferredHeight
            super.init(nibName: nil, bundle: nil)
            addChild(rootViewController)
            rootViewController.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(rootViewController.view)
            NSLayoutConstraint.activate([
                rootViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                rootViewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                rootViewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                rootViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError()
        }

        deinit {
            if let keyEventMonitor {
                NSEvent.removeMonitor(keyEventMonitor)
            }
        }

        override open func loadView() {
            let overlayView = AlertOverlayView(frame: NSRect(x: 0, y: 0, width: 480, height: 320))
            overlayView.owner = self
            view = overlayView
        }

        override open func viewDidLoad() {
            super.viewDidLoad()
            defer { contentViewDidLoad() }

            if let dimmingView = dimmingView as? AlertDimmingView {
                dimmingView.clickHandler = { [weak self] in
                    self?.dimmingViewTapped()
                }
            }
            dimmingView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(dimmingView)
            NSLayoutConstraint.activate([
                dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
                dimmingView.leftAnchor.constraint(equalTo: view.leftAnchor),
                dimmingView.rightAnchor.constraint(equalTo: view.rightAnchor),
                dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

            view.addLayoutGuide(contentLayoutGuide)
            NSLayoutConstraint.activate([
                contentLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
                contentLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
                contentLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
                contentLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            ])

            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 16
            contentView.layer?.cornerCurve = .continuous
            contentView.layer?.masksToBounds = true
            if #available(macOS 14.0, *) {
                contentView.clipsToBounds = true
            }
            contentView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(contentView)
            NSLayoutConstraint.activate([
                contentView.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor),
                contentView.centerYAnchor.constraint(equalTo: contentLayoutGuide.centerYAnchor),
            ])
            // Every size constraint stays below `windowSizeStayPut`, so the
            // alert fits itself to the window and never resizes the window.
            // The preferred size gives way to the window first, like UIKit's
            // `min(preferred, available)`; content that still does not fit
            // scrolls, and only then overflows the window.
            let containment = [
                contentView.leadingAnchor.constraint(greaterThanOrEqualTo: contentLayoutGuide.leadingAnchor),
                contentView.trailingAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.trailingAnchor),
                contentView.topAnchor.constraint(greaterThanOrEqualTo: contentLayoutGuide.topAnchor),
                contentView.bottomAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.bottomAnchor),
            ]
            for constraint in containment {
                constraint.priority = AlertLayoutPriority.containment
            }
            NSLayoutConstraint.activate(containment)
            if let preferredWidth {
                let constraint = contentView.widthAnchor.constraint(equalToConstant: preferredWidth)
                constraint.priority = AlertLayoutPriority.preferredSize
                constraint.isActive = true
            }
            if let preferredHeight {
                let constraint = contentView.heightAnchor.constraint(equalToConstant: preferredHeight)
                constraint.priority = AlertLayoutPriority.preferredSize
                constraint.isActive = true
            }

            contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(contentBackgroundView, positioned: .below, relativeTo: nil)
            NSLayoutConstraint.activate([
                contentBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
                contentBackgroundView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                contentBackgroundView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                contentBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])

            view.setAccessibilityRole(.group)
            contentView.setAccessibilityElement(true)
            contentView.setAccessibilityRole(.group)
        }

        open func contentViewDidLoad() {}

        override open func viewWillLayout() {
            super.viewWillLayout()
            contentViewLayout(in: contentView.bounds)
        }

        open func contentViewLayout(in bounds: CGRect) {
            _ = bounds
        }

        // MARK: Hooks for subclasses in this module

        /// The view that takes key focus once the alert is on screen.
        var preferredInitialFirstResponder: NSView? {
            nil
        }

        /// Runs the action Return triggers; returns false when there is none.
        func performDefaultAction() -> Bool {
            false
        }

        /// Called once the overlay has left the window after a dismissal.
        func alertDidFinishDismissal() {}

        // MARK: Interaction

        @objc open func dimmingViewTapped() {
            if shouldDismissWhenTappedAround {
                dismiss(animated: true)
            } else {
                contentViewBounce()
            }
        }

        @objc open func escapePressed() {
            if shouldDismissWhenEscapeKeyPressed {
                dismiss(animated: true)
            } else {
                contentViewBounce()
            }
        }

        override open func cancelOperation(_: Any?) {
            escapePressed()
        }

        override open func keyDown(with event: NSEvent) {
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard !modifiers.contains(.command) else {
                super.keyDown(with: event)
                return
            }
            switch event.keyCode {
            case AlertKeyCode.escape:
                escapePressed()
            case AlertKeyCode.return, AlertKeyCode.keypadEnter:
                if !performDefaultAction() {
                    NSSound.beep()
                }
            case AlertKeyCode.tab:
                super.keyDown(with: event)
            default:
                // Keep typing from reaching the content behind the alert.
                NSSound.beep()
            }
        }

        // MARK: Dismissal

        /// Dismisses the alert. Mirrors `UIViewController.dismiss(animated:completion:)`
        /// so call sites read the same on both platforms.
        open func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
            if let completion {
                dismissalCompletions.append(completion)
            }
            switch transitionState {
            case .presenting:
                // Finish appearing first; the dismissal starts right after.
                pendingDismissal = animated
                return
            case .dismissing:
                return
            case .idle, .presented:
                break
            }
            guard let presenter = presentingViewController else {
                finishDismissalCompletions()
                return
            }
            guard isAttached else {
                // Presented by something other than `AlertPresentationAnimator`,
                // so no animation will report back.
                presenter.dismiss(self)
                finishDismissalCompletions()
                return
            }
            animatesNextDismissal = animated
            presenter.dismiss(self)
        }

        private func finishDismissalCompletions() {
            let completions = dismissalCompletions
            dismissalCompletions.removeAll()
            completions.forEach { $0() }
        }

        // MARK: Presentation (driven by AlertPresentationAnimator)

        /// Adds the overlay to `containerView`, covering `sibling` and stacked
        /// right above it, or covering all of `containerView` without one.
        func attachOverlay(to containerView: NSView, above sibling: NSView? = nil) {
            let window = containerView.window
            previousFirstResponder = Self.restorableResponder(window?.firstResponder)

            view.frame = sibling?.frame ?? containerView.bounds
            view.autoresizingMask = [.width, .height]
            containerView.addSubview(view, positioned: .above, relativeTo: sibling)
            isAttached = true
            // Wrapping labels settle their width on the first pass and their
            // height on the second.
            view.layoutSubtreeIfNeeded()
            view.layoutSubtreeIfNeeded()

            window?.makeFirstResponder(preferredInitialFirstResponder ?? view)
            installKeyEventMonitor()
            NSAccessibility.post(element: contentView, notification: .layoutChanged)
        }

        private func detachOverlay() {
            removeKeyEventMonitor()
            let window = view.window
            view.removeFromSuperview()
            isAttached = false
            guard let window else { return }
            restorePreviousFirstResponder(in: window)
        }

        /// Hands focus back to what had it before the alert, unless focus has
        /// already moved elsewhere, such as to a newer alert.
        private func restorePreviousFirstResponder(in window: NSWindow) {
            defer { previousFirstResponder = nil }
            guard let previousFirstResponder,
                  Self.isResponder(previousFirstResponder, in: window)
            else { return }
            if let current = window.firstResponder, current !== window {
                guard let currentView = current as? NSView else { return }
                guard currentView.isDescendant(of: view) else {
                    handOverPreviousFirstResponder(to: currentView, previousFirstResponder)
                    return
                }
            }
            window.makeFirstResponder(previousFirstResponder)
        }

        /// A newer alert that took focus from this one restores this
        /// alert's previous responder when it closes instead.
        private func handOverPreviousFirstResponder(to focusedView: NSView, _ responder: NSResponder) {
            var candidate: NSView? = focusedView
            while let current = candidate, !(current is AlertOverlayView) {
                candidate = current.superview
            }
            guard let newerAlert = (candidate as? AlertOverlayView)?.owner, newerAlert !== self else { return }
            if let inherited = newerAlert.previousFirstResponder as? NSView,
               !inherited.isDescendant(of: view)
            {
                return
            }
            newerAlert.previousFirstResponder = responder
        }

        func runPresentationAnimation(animated: Bool) {
            transitionState = .presenting
            dimmingView.alphaValue = 0.25
            contentView.alphaValue = 1

            guard animated, let dimmingLayer = dimmingView.layer, let contentLayer = contentView.layer else {
                finishPresentation()
                return
            }

            CATransaction.begin()
            // AppKit releases the presented controller once the animator returns,
            // so the block keeps it alive until the transition finishes.
            CATransaction.setCompletionBlock { [self] in
                finishPresentation()
            }
            dimmingLayer.add(
                AlertAnimation.fade(from: 0, to: 0.25, duration: 0.25),
                forKey: AlertAnimation.opacityKey
            )
            if AlertAnimation.prefersReducedMotion {
                contentLayer.add(
                    AlertAnimation.fade(from: 0, to: 1, duration: 0.2),
                    forKey: AlertAnimation.opacityKey
                )
            } else {
                contentLayer.add(
                    AlertAnimation.springFade(from: 0, to: 1),
                    forKey: AlertAnimation.opacityKey
                )
                contentLayer.add(
                    AlertAnimation.springScale(from: 1.1, to: 1, in: contentLayer),
                    forKey: AlertAnimation.transformKey
                )
            }
            CATransaction.commit()
        }

        private func finishPresentation() {
            guard transitionState == .presenting else { return }
            transitionState = .presented
            let completion = presentationCompletion
            presentationCompletion = nil
            completion?()
            guard let animated = pendingDismissal else { return }
            pendingDismissal = nil
            dismiss(animated: animated)
        }

        func runDismissalAnimation(animated: Bool) {
            transitionState = .dismissing
            // Hand the keyboard back right away instead of after the fade.
            removeKeyEventMonitor()
            if let window = view.window {
                restorePreviousFirstResponder(in: window)
            }

            guard animated, let dimmingLayer = dimmingView.layer, let contentLayer = contentView.layer else {
                finishDismissal()
                return
            }

            let dimmingOpacity = dimmingLayer.presentation()?.opacity ?? Float(dimmingView.alphaValue)
            let contentOpacity = contentLayer.presentation()?.opacity ?? Float(contentView.alphaValue)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            dimmingView.alphaValue = 0
            contentView.alphaValue = 0
            // AppKit releases the presented controller once the animator returns,
            // so the block keeps it alive until the transition finishes.
            CATransaction.setCompletionBlock { [self] in
                finishDismissal()
            }
            dimmingLayer.add(
                AlertAnimation.fade(from: dimmingOpacity, to: 0, duration: 0.2),
                forKey: AlertAnimation.opacityKey
            )
            contentLayer.add(
                AlertAnimation.fade(from: contentOpacity, to: 0, duration: 0.2),
                forKey: AlertAnimation.opacityKey
            )
            if !AlertAnimation.prefersReducedMotion {
                contentLayer.add(
                    AlertAnimation.scale(from: 1, to: 1.05, in: contentLayer, duration: 0.2),
                    forKey: AlertAnimation.transformKey
                )
            }
            CATransaction.commit()
        }

        private func finishDismissal() {
            guard transitionState == .dismissing else { return }
            dimmingView.layer?.removeAllAnimations()
            contentView.layer?.removeAllAnimations()
            detachOverlay()
            transitionState = .idle
            animatesNextDismissal = true
            alertDidFinishDismissal()
            finishDismissalCompletions()
        }

        // MARK: Animation helpers

        func contentViewBounce() {
            guard let layer = contentView.layer,
                  !AlertAnimation.prefersReducedMotion
            else { return }
            layer.add(AlertAnimation.bounce(in: layer), forKey: AlertAnimation.bounceKey)
        }

        func animateContentSizeChange(_ updates: @escaping () -> Void) {
            view.layoutSubtreeIfNeeded()
            guard view.window != nil, !AlertAnimation.prefersReducedMotion else {
                updates()
                view.layoutSubtreeIfNeeded()
                return
            }
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.35
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                context.allowsImplicitAnimation = true
                updates()
                self.view.layoutSubtreeIfNeeded()
            }
        }

        // MARK: Keyboard routing

        /// Return and Escape reach the alert before key equivalents of the
        /// content behind it, such as a default button, can claim them.
        private func installKeyEventMonitor() {
            removeKeyEventMonitor()
            keyEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self else { return event }
                return handleMonitoredKeyDown(event) ? nil : event
            }
        }

        private func removeKeyEventMonitor() {
            guard let keyEventMonitor else { return }
            NSEvent.removeMonitor(keyEventMonitor)
            self.keyEventMonitor = nil
        }

        private func handleMonitoredKeyDown(_ event: NSEvent) -> Bool {
            guard let window = view.window, event.window === window else { return false }
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard !modifiers.contains(.command), !modifiers.contains(.control) else { return false }

            let firstResponder = window.firstResponder
            if let textView = firstResponder as? NSTextView, textView.hasMarkedText() {
                // Let the input method finish or cancel its composition.
                return false
            }

            switch event.keyCode {
            case AlertKeyCode.escape:
                escapePressed()
                return true
            case AlertKeyCode.return, AlertKeyCode.keypadEnter:
                // A focused text field submits and a focused button presses
                // itself; anything else runs the accent action.
                if let responderView = firstResponder as? NSView,
                   responderView.isDescendant(of: view),
                   responderView is NSTextView || responderView is AlertButton
                {
                    return false
                }
                if !performDefaultAction() {
                    NSSound.beep()
                }
                return true
            default:
                return false
            }
        }

        /// The responder to restore later; a field editor stands in for its text field.
        private static func restorableResponder(_ responder: NSResponder?) -> NSResponder? {
            guard let textView = responder as? NSTextView, textView.isFieldEditor else {
                return responder
            }
            return textView.delegate as? NSResponder
        }

        private static func isResponder(_ responder: NSResponder, in window: NSWindow) -> Bool {
            if let view = responder as? NSView {
                return view.window === window
            }
            return responder === window || responder === window.windowController
        }
    }

    /// Layout priorities of the alert card, all below `windowSizeStayPut`.
    enum AlertLayoutPriority {
        static let containment = NSLayoutConstraint.Priority(NSLayoutConstraint.Priority.windowSizeStayPut.rawValue - 1)
        static let preferredSize = NSLayoutConstraint.Priority(containment.rawValue - 10)
        /// Text scrolls once the card reaches the window's height.
        static let textHeight = NSLayoutConstraint.Priority(preferredSize.rawValue - 10)
        /// Text and buttons follow the card width instead of setting it.
        static let horizontalFit = NSLayoutConstraint.Priority.defaultLow
    }

    /// Root view of an alert: covers the window content and keeps the
    /// pointer from reaching the views behind it.
    final class AlertOverlayView: NSView {
        weak var owner: AlertBaseController?

        override var acceptsFirstResponder: Bool {
            true
        }

        override var mouseDownCanMoveWindow: Bool {
            false
        }

        override func resetCursorRects() {
            addCursorRect(bounds, cursor: .arrow)
        }

        override func mouseDown(with _: NSEvent) {}
        override func rightMouseDown(with _: NSEvent) {}
        override func otherMouseDown(with _: NSEvent) {}
        override func scrollWheel(with _: NSEvent) {}

        override func menu(for _: NSEvent) -> NSMenu? {
            nil
        }
    }

    final class AlertDimmingView: AlertColorView {
        var clickHandler: () -> Void = {}

        init() {
            super.init(fillColor: .black)
            alphaValue = 0
            setAccessibilityElement(false)
        }

        override var mouseDownCanMoveWindow: Bool {
            false
        }

        override func acceptsFirstMouse(for _: NSEvent?) -> Bool {
            true
        }

        override func mouseDown(with _: NSEvent) {
            clickHandler()
        }

        override func rightMouseDown(with _: NSEvent) {}
        override func otherMouseDown(with _: NSEvent) {}
        override func scrollWheel(with _: NSEvent) {}

        override func menu(for _: NSEvent) -> NSMenu? {
            nil
        }
    }
#endif
