//
//  SeparatorView.swift
//  AlertController
//
//  Created by 秋星桥 on 2/22/25.
//

import UIKit

class HorizontalSeprator: UIView {
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
