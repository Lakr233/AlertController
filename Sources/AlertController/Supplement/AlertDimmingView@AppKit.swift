//
//  AlertDimmingView@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit dims with a plain UIView set up in AlertBaseController.swift.
#elseif canImport(AppKit)
    import AppKit

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
