//
//  HorizontalSeparator.swift
//  AlertController
//
//  Created by 秋星桥 on 2/22/25.
//

#if canImport(UIKit)
    import UIKit

    class HorizontalSeparator: UIView {
        init() {
            super.init(frame: .zero)
            backgroundColor = AlertControllerConfiguration.separatorColor
            heightAnchor.constraint(equalToConstant: 1).isActive = true
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }
    }
#endif
