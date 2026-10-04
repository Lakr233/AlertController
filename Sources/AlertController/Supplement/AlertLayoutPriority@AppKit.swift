//
//  AlertLayoutPriority@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// AppKit only: UIKit lays out the alert card without these priorities.
#elseif canImport(AppKit)
    import AppKit

    /// Layout priorities of the alert card, all below `windowSizeStayPut`.
    enum AlertLayoutPriority {
        static let containment = NSLayoutConstraint.Priority(NSLayoutConstraint.Priority.windowSizeStayPut.rawValue - 1)
        static let preferredSize = NSLayoutConstraint.Priority(containment.rawValue - 10)
        /// Text scrolls once the card reaches the window's height.
        static let textHeight = NSLayoutConstraint.Priority(preferredSize.rawValue - 10)
        /// Text and buttons follow the card width instead of setting it.
        static let horizontalFit = NSLayoutConstraint.Priority.defaultLow
    }
#endif
