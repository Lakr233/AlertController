//
//  AlertInputContentController.swift
//  AlertController
//
//  Created by 秋星桥 on 2/22/25.
//

import UIKit

class AlertInputContentController: AlertContentController {
    let field = InputField()

    private var submitAction: (ActionContext) -> Void = { _ in }

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
        field.textReturnAction = { [weak self] in
            self?.callSubmit()
        }
        customViews.append(field)
        submitAction = onSubmit
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        field.textField.becomeFirstResponder()
        field.updateQuickOptionImage()
    }

    private func callSubmit() {
        submitAction(context)
        submitAction = { _ in }
    }
}

private class UITextFieldWithoutEscapeToClear: UITextField {
    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(
                input: UIKeyCommand.inputEscape,
                modifierFlags: [],
                action: #selector(stub)
            ),
        ]
    }

    @objc func stub() {}
}

class InputField: UIView, UITextFieldDelegate {
    fileprivate let textField = UITextFieldWithoutEscapeToClear(frame: .zero)

    var textPublisher: (String) -> Void = { _ in }
    var textReturnAction: () -> Void = {}
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
        textField.allowsEditingTextAttributes = false

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
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func updateQuickOptionImage() {
        if (textField.text ?? "").isEmpty == true {
            quickOptionButton.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        } else {
            quickOptionButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
    }

    @objc func tappedOptionButton() {
        if (textField.text ?? "").isEmpty == true {
            textField.text = UIPasteboard.general.string
            valueChanged()
        } else {
            textField.text = ""
            valueChanged()
        }
    }

    @objc func valueChanged() {
        updateQuickOptionImage()
        collectValue()
    }

    @objc func collectValue() {
        textPublisher(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textReturnAction()
        textReturnAction = {}
        return true
    }
}
