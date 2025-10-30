//
//  AlertButton.swift
//  AlertController
//
//  Created by 秋星桥 on 2/22/25.
//

import UIKit

class AlertButton: UIView {
    let action: ActionContext.Action

    let label = UILabel()

    init(action: ActionContext.Action) {
        self.action = action
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)

        label.text = action.title
        label.textColor = action.foregroundColor
        label.textAlignment = .center
        label.font = action.font

        layer.borderWidth = 1
        layer.borderColor = action.borderColor.cgColor
        backgroundColor = action.backgroundColor

        layer.cornerRadius = 12
        layer.cornerCurve = .continuous

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])

        isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(gesture)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    @objc func tapped() {
        alpha = 0.75
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
        Task { @MainActor in
            self.action.block()
        }
    }
}

extension ActionContext.Action {
    var foregroundColor: UIColor {
        switch attribute {
        case .accent:
            .white
        case .normal:
            AlertControllerConfiguration.accentColor
        }
    }

    var backgroundColor: UIColor {
        switch attribute {
        case .accent:
            AlertControllerConfiguration.accentColor
        case .normal:
            .clear
        }
    }

    var borderColor: UIColor {
        switch attribute {
        default:
            AlertControllerConfiguration.accentColor
        }
    }

    var font: UIFont {
        switch attribute {
        case .accent:
            .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)
        case .normal:
            .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        }
    }
}
