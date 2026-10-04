//
//  SeparatorView@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit implementation lives in SeparatorView.swift.
#elseif canImport(AppKit)
    import AppKit

    class HorizontalSeprator: AlertColorView {
        init() {
            super.init(fillColor: AlertControllerConfiguration.separatorColor)
            heightAnchor.constraint(equalToConstant: 1).isActive = true
            setAccessibilityElement(false)
        }
    }
#endif
