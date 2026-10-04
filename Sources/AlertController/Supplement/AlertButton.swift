//
//  AlertButton.swift
//  AlertController
//
//  Created by 秋星桥 on 2/22/25.
//

#if canImport(UIKit)
    import UIKit

    class AlertButton: UIView {
        let action: ActionContext.Action
        let attribute: ActionContext.Action.Attribute

        let label = UILabel()

        init(
            action: ActionContext.Action,
            attribute: ActionContext.Action.Attribute
        ) {
            self.action = action
            self.attribute = attribute
            super.init(frame: .zero)

            translatesAutoresizingMaskIntoConstraints = false

            addSubview(label)

            label.text = action.title
            label.textColor = attribute.foregroundColor
            label.textAlignment = .center
            label.font = attribute.font
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping

            layer.borderWidth = 1
            updateBorderColor()
            backgroundColor = attribute.backgroundColor

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

            isAccessibilityElement = true
            accessibilityTraits = .button
            accessibilityLabel = action.title
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            updateBorderColor()
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            updateBorderColor()
        }

        private func updateBorderColor() {
            layer.borderColor = attribute.borderColor.resolvedColor(with: traitCollection).cgColor
        }

        override var canBecomeFocused: Bool {
            true
        }

        override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
            guard isFocused else {
                super.pressesBegan(presses, with: event)
                return
            }
            let activates = presses.contains { press in
                if press.type == .select {
                    return true
                }
                guard let keyCode = press.key?.keyCode else { return false }
                return keyCode == .keyboardReturnOrEnter || keyCode == .keyboardSpacebar
            }
            guard activates else {
                super.pressesBegan(presses, with: event)
                return
            }
            tapped()
        }

        override func accessibilityActivate() -> Bool {
            tapped()
            return true
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
#endif
