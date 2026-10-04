//
//  AlertButton@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit implementation lives in AlertButton.swift.
#elseif canImport(AppKit)
    import AppKit

    class AlertButton: AlertColorView {
        let action: ActionContext.Action
        let attribute: ActionContext.Action.Attribute

        let label: NSTextField

        private var isPressed = false {
            didSet { alphaValue = isPressed ? 0.75 : 1 }
        }

        init(
            action: ActionContext.Action,
            attribute: ActionContext.Action.Attribute
        ) {
            self.action = action
            self.attribute = attribute
            label = NSTextField(wrappingLabelWithString: action.title)
            super.init(fillColor: attribute.backgroundColor)

            translatesAutoresizingMaskIntoConstraints = false
            borderColor = attribute.borderColor
            borderWidth = 1
            cornerRadius = 12
            focusRingType = .default

            let insets = AlertActionLayoutPolicy.buttonContentInsets
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = attribute.foregroundColor
            label.alignment = .center
            label.font = attribute.font
            label.isSelectable = false
            label.lineBreakMode = .byWordWrapping
            label.setAccessibilityElement(false)
            label.setContentCompressionResistancePriority(AlertLayoutPriority.horizontalFit, for: .horizontal)
            label.setContentHuggingPriority(AlertLayoutPriority.horizontalFit, for: .horizontal)
            addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
            ])

            setAccessibilityElement(true)
            setAccessibilityRole(.button)
            setAccessibilityLabel(action.title)
        }

        override func layout() {
            super.layout()
            let insets = AlertActionLayoutPolicy.buttonContentInsets
            let width = max(bounds.width - insets.left - insets.right, 0)
            guard width > 0, label.preferredMaxLayoutWidth != width else { return }
            label.preferredMaxLayoutWidth = width
        }

        // MARK: Mouse

        override func hitTest(_ point: NSPoint) -> NSView? {
            // Clicks on the label belong to the button.
            super.hitTest(point) == nil ? nil : self
        }

        override func acceptsFirstMouse(for _: NSEvent?) -> Bool {
            true
        }

        override func mouseDown(with _: NSEvent) {
            isPressed = true
        }

        override func mouseDragged(with event: NSEvent) {
            isPressed = isInside(event)
        }

        override func mouseUp(with event: NSEvent) {
            let activates = isPressed && isInside(event)
            isPressed = false
            guard activates else { return }
            tapped()
        }

        private func isInside(_ event: NSEvent) -> Bool {
            let location = convert(event.locationInWindow, from: nil)
            return bounds.contains(location)
        }

        // MARK: Keyboard

        /// Takes key focus only with Full Keyboard Access, like `NSButton`.
        override var acceptsFirstResponder: Bool {
            NSApp.isFullKeyboardAccessEnabled
        }

        override var canBecomeKeyView: Bool {
            acceptsFirstResponder
        }

        override var focusRingMaskBounds: NSRect {
            bounds
        }

        override func drawFocusRingMask() {
            NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).fill()
        }

        override func keyDown(with event: NSEvent) {
            switch event.keyCode {
            case AlertKeyCode.space, AlertKeyCode.return, AlertKeyCode.keypadEnter:
                tapped()
            default:
                super.keyDown(with: event)
            }
        }

        // MARK: Accessibility

        override func accessibilityPerformPress() -> Bool {
            tapped()
            return true
        }

        // MARK: Action

        func tapped() {
            alphaValue = 0.75
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.25
                self.animator().alphaValue = 1
            }
            Task { @MainActor in
                self.action.block()
            }
        }
    }

    /// Virtual key codes for the keys the alert handles itself.
    enum AlertKeyCode {
        static let `return`: UInt16 = 36
        static let tab: UInt16 = 48
        static let space: UInt16 = 49
        static let escape: UInt16 = 53
        static let keypadEnter: UInt16 = 76
    }
#endif
