//
//  HorizontalSeparator@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit implementation lives in HorizontalSeparator.swift.
#elseif canImport(AppKit)
    import AppKit

    class HorizontalSeparator: AlertColorView {
        init() {
            super.init(fillColor: AlertControllerConfiguration.separatorColor)
            heightAnchor.constraint(equalToConstant: 1).isActive = true
            setAccessibilityElement(false)
        }
    }
#endif
