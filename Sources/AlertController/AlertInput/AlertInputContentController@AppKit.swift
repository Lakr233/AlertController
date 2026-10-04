//
//  AlertInputContentController@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit implementation lives in AlertInputContentController.swift.
#elseif canImport(AppKit)
    import AppKit

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
            let trimmedText = originalText.trimmingCharacters(in: .whitespacesAndNewlines)
            context.userObject = trimmedText
            field.textField.placeholderString = placeholder
            field.textField.stringValue = trimmedText
            field.updateQuickOptionImage()
            field.textPublisher = { [weak self] text in
                self?.context.userObject = text
            }
            field.textReturnAction = { [weak self] in
                self?.callSubmit()
            }
            customViews.append(field)
            submitAction = onSubmit
        }

        override var initialFirstResponder: NSView? {
            field.textField
        }

        override var keyViews: [NSView] {
            [field.textField] + super.keyViews
        }

        private func callSubmit() {
            submitAction(context)
            submitAction = { _ in }
        }
    }

    /// Single-line field that keeps the standard editing shortcuts working
    /// in hosts without an Edit menu.
    final class AlertInputTextField: NSTextField {
        override func performKeyEquivalent(with event: NSEvent) -> Bool {
            guard currentEditor() != nil else {
                return super.performKeyEquivalent(with: event)
            }
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard modifiers == .command else {
                return super.performKeyEquivalent(with: event)
            }
            let selector: Selector? = switch event.charactersIgnoringModifiers {
            case "x": #selector(NSText.cut(_:))
            case "c": #selector(NSText.copy(_:))
            case "v": #selector(NSText.paste(_:))
            case "a": #selector(NSResponder.selectAll(_:))
            default: nil
            }
            guard let selector else {
                return super.performKeyEquivalent(with: event)
            }
            return NSApp.sendAction(selector, to: nil, from: self)
        }
    }

    class InputField: AlertColorView, NSTextFieldDelegate {
        let textField = AlertInputTextField()

        var textPublisher: (String) -> Void = { _ in }
        var textReturnAction: () -> Void = {}
        let quickOptionButton = NSButton()

        init() {
            super.init(fillColor: AlertControllerConfiguration.accentColor.withAlphaComponent(0.1))
            translatesAutoresizingMaskIntoConstraints = false
            cornerRadius = 8
            heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true

            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.isBordered = false
            textField.isBezeled = false
            textField.drawsBackground = false
            textField.focusRingType = .none
            textField.isEditable = true
            textField.isSelectable = true
            textField.textColor = NSColor.labelColor.withAlphaComponent(0.9)
            textField.font = .alertSystemFont(forTextStyle: .body)
            textField.usesSingleLineMode = true
            textField.lineBreakMode = .byTruncatingTail
            textField.cell?.isScrollable = true
            textField.cell?.wraps = false
            textField.isAutomaticTextCompletionEnabled = false
            textField.allowsEditingTextAttributes = false
            textField.delegate = self

            quickOptionButton.translatesAutoresizingMaskIntoConstraints = false
            quickOptionButton.isBordered = false
            quickOptionButton.bezelStyle = .regularSquare
            quickOptionButton.imagePosition = .imageOnly
            quickOptionButton.imageScaling = .scaleProportionallyDown
            quickOptionButton.contentTintColor = AlertControllerConfiguration.accentColor
            quickOptionButton.refusesFirstResponder = true
            quickOptionButton.target = self
            quickOptionButton.action = #selector(tappedOptionButton)
            quickOptionButton.setContentHuggingPriority(.required, for: .horizontal)
            updateQuickOptionImage()

            addSubview(textField)
            addSubview(quickOptionButton)

            NSLayoutConstraint.activate([
                textField.centerYAnchor.constraint(equalTo: centerYAnchor),
                textField.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 4),
                textField.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -4),
                textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),

                quickOptionButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                quickOptionButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
                quickOptionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
                quickOptionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                quickOptionButton.widthAnchor.constraint(equalTo: quickOptionButton.heightAnchor),
            ])
        }

        func updateQuickOptionImage() {
            let symbolName = textField.stringValue.isEmpty ? "doc.on.clipboard" : "xmark.circle.fill"
            quickOptionButton.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
        }

        @objc func tappedOptionButton() {
            if textField.stringValue.isEmpty {
                setText(NSPasteboard.general.string(forType: .string) ?? "")
            } else {
                setText("")
            }
            valueChanged()
        }

        private func setText(_ text: String) {
            guard let editor = textField.currentEditor() as? NSTextView else {
                textField.stringValue = text
                return
            }
            editor.string = text
            editor.selectedRange = NSRange(location: (text as NSString).length, length: 0)
        }

        func valueChanged() {
            updateQuickOptionImage()
            textPublisher(textField.stringValue)
        }

        // MARK: NSTextFieldDelegate

        func controlTextDidChange(_: Notification) {
            valueChanged()
        }

        func control(
            _: NSControl,
            textView _: NSTextView,
            doCommandBy commandSelector: Selector
        ) -> Bool {
            switch commandSelector {
            case #selector(NSResponder.insertNewline(_:)):
                valueChanged()
                textReturnAction()
                textReturnAction = {}
                return true
            case #selector(NSResponder.cancelOperation(_:)):
                // Escape belongs to the alert instead of clearing the text.
                hostingAlertController()?.escapePressed()
                return true
            default:
                return false
            }
        }

        private func hostingAlertController() -> AlertBaseController? {
            var responder = textField.nextResponder
            while let current = responder {
                if let alertController = current as? AlertBaseController {
                    return alertController
                }
                responder = current.nextResponder
            }
            return nil
        }
    }
#endif
