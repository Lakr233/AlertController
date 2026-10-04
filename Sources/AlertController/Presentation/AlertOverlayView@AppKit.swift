//
//  AlertOverlayView@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit presents alerts through AlertPresentationController.
#elseif canImport(AppKit)
    import AppKit

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
#endif
