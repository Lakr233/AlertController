//
//  AlertInputContentController.swift
//  AlertController
//
//  Created by 秋星桥 on 2/22/25.
//

import UIKit

class AlertInputContentController: AlertContentController {
    let field = InputField()

    init(
        title: String = "",
        message: String = "",
        originalText: String,
        placeholder: String,
        setupActions: @escaping (ActionContext) -> Void,
        onSubmit: @escaping (ActionContext) -> Void
    ) {
        super.init(title: title, message: message, setupActions: setupActions)
        context.userObject = originalText
        field.textField.placeholder = placeholder
        field.textField.text = originalText.trimmingCharacters(in: .whitespacesAndNewlines)
        field.textPublisher = { [weak self] text in
            self?.context.userObject = text
        }
        let captureContext = context
        field.stopPublisher = { onSubmit(captureContext) }
        customViews.append(field)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        field.textField.becomeFirstResponder()
        field.updateQuickOptionImage()
    }
}

class InputField: UIView, UITextFieldDelegate {
    let textField = UITextField(frame: .zero)

    var textPublisher: (String) -> Void = { _ in }
    var stopPublisher: () -> Void = {}

    let quickOptionButton = UIButton()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 32).isActive = true

        backgroundColor = AlertControllerConfiguration.accentColor.withAlphaComponent(0.1)
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous

        textField.textColor = .label.withAlphaComponent(0.9)
        textField.font = .preferredFont(forTextStyle: .footnote)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        quickOptionButton.translatesAutoresizingMaskIntoConstraints = false
        quickOptionButton.imageView?.contentMode = .scaleAspectFit
        quickOptionButton.tintColor = AlertControllerConfiguration.accentColor
        quickOptionButton.addTarget(self, action: #selector(tappedOptionButton), for: .touchUpInside)
        updateQuickOptionImage()

        addSubview(textField)
        addSubview(quickOptionButton)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            quickOptionButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            quickOptionButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            quickOptionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            quickOptionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            quickOptionButton.widthAnchor.constraint(equalTo: quickOptionButton.heightAnchor),
        ])

        textField.delegate = self
        textField.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func updateQuickOptionImage() {
        if textField.text?.isEmpty == true {
            quickOptionButton.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        } else {
            quickOptionButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
    }

    @objc func tappedOptionButton() {
        if textField.text?.isEmpty == true {
            textField.text = UIPasteboard.general.string
            valueChanged()
        } else {
            textField.text = ""
            valueChanged()
        }
    }

    func textFieldDidEndEditing(_: UITextField) {
        collectValue()
        stopPublisher()
    }

    @objc func valueChanged() {
        updateQuickOptionImage()
        collectValue()
    }

    @objc func collectValue() {
        textPublisher(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
}
