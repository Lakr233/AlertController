//
//  AlertContentController@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit implementation lives in AlertContentController.swift.
#elseif canImport(AppKit)
    import AppKit

    class AlertContentController: NSViewController {
        /// Width the alert card asks for; seeds wrapping labels before the
        /// first layout pass measures the real width.
        static let preferredWidth: CGFloat = 350
        static let horizontalInset: CGFloat = 16

        let context: ActionContext
        private(set) var messageLabel: NSTextField?

        let messageTitle: String
        let messageContent: String
        let stackView = NSStackView()
        private let textScrollView = NSScrollView()
        private let textStackView = NSStackView()

        let backgroundView = AlertColorView(
            fillColor: AlertControllerConfiguration.backgroundColor.withAlphaComponent(0.5)
        )
        private var actionPresentations = [PresentedAlertAction]()
        private(set) var actionButtons = [AlertButton]()
        private var actionAxisConstraints = [PlatformLayoutAxis: [NSLayoutConstraint]]()
        private var appliedActionAxis: PlatformLayoutAxis?

        init(
            title: String = "",
            message: String = "",
            context: ActionContext = .init(),
            setupActions: @escaping (ActionContext) -> Void
        ) {
            self.context = context
            messageTitle = title
            messageContent = message
            super.init(nibName: nil, bundle: nil)

            context.bind(to: self)
            setupActions(context)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        var customViews: [NSView] = []

        /// The view that takes key focus when the alert appears.
        var initialFirstResponder: NSView? {
            nil
        }

        /// Views reachable with Tab, in order.
        var keyViews: [NSView] {
            actionButtons
        }

        func updateMessage(_ message: String, animated: Bool) {
            guard animated, isViewLoaded, let messageLabel else {
                messageLabel?.stringValue = message
                messageLabel?.isHidden = message.isEmpty
                updateTextScrollViewVisibility()
                return
            }

            let applyText = { [weak self] in
                let transition = CATransition()
                transition.type = .fade
                transition.duration = 0.25
                messageLabel.layer?.add(transition, forKey: "AlertController.crossfade")
                messageLabel.stringValue = message
                messageLabel.isHidden = message.isEmpty
                self?.updateTextScrollViewVisibility()
            }

            if let alertController = parent as? AlertBaseController {
                alertController.animateContentSizeChange(applyText)
            } else {
                applyText()
            }
        }

        override func loadView() {
            view = NSView()
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(backgroundView)
            NSLayoutConstraint.activate([
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
                backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

            view.addSubview(stackView)
            stackView.orientation = .vertical
            stackView.spacing = context.spacing
            stackView.distribution = .fill
            stackView.alignment = .centerX
            stackView.detachesHiddenViews = true
            stackView.setHuggingPriority(AlertLayoutPriority.horizontalFit, for: .horizontal)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: context.spacing),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -context.spacing),
            ])

            if let image = AlertControllerConfiguration.alertImage {
                let imageView = AlertImageView(image: image)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.heightAnchor.constraint(equalToConstant: 64),
                    imageView.widthAnchor.constraint(equalToConstant: 64),
                ])
                stackView.addArrangedSubview(imageView)
            }

            setupTextViews()

            for customView in customViews {
                stackView.addArrangedSubview(customView)
                customView.translatesAutoresizingMaskIntoConstraints = false
                let inset = customView is HorizontalSeprator ? 0 : Self.horizontalInset
                pinHorizontally(customView, inset: inset)
            }

            setupActionButtons()
            updateKeyViewLoop()
        }

        override func viewDidLayout() {
            super.viewDidLayout()

            let width = max(stackView.bounds.width - Self.horizontalInset * 2, 0)
            for label in textStackView.arrangedSubviews.compactMap({ $0 as? NSTextField }) {
                guard width > 0, label.preferredMaxLayoutWidth != width else { continue }
                label.preferredMaxLayoutWidth = width
            }

            updateButtonAxisIfNeeded()
        }

        /// Presses the accent button, which Return triggers.
        func performAccentAction() -> Bool {
            guard let button = actionButtons.first(where: { $0.attribute == .accent }) else {
                return false
            }
            button.tapped()
            return true
        }

        // MARK: Text

        /// Title and message scroll when they do not fit, so the actions
        /// below always stay visible.
        private func setupTextViews() {
            let labelWidth = Self.preferredWidth - Self.horizontalInset * 2

            textStackView.orientation = .vertical
            textStackView.spacing = context.spacing
            textStackView.alignment = .centerX
            textStackView.distribution = .fill
            textStackView.detachesHiddenViews = true
            textStackView.setHuggingPriority(AlertLayoutPriority.horizontalFit, for: .horizontal)
            textStackView.translatesAutoresizingMaskIntoConstraints = false

            let documentView = AlertFlippedView()
            documentView.translatesAutoresizingMaskIntoConstraints = false
            documentView.addSubview(textStackView)

            textScrollView.translatesAutoresizingMaskIntoConstraints = false
            textScrollView.drawsBackground = false
            textScrollView.borderType = .noBorder
            textScrollView.hasVerticalScroller = true
            textScrollView.hasHorizontalScroller = false
            textScrollView.autohidesScrollers = true
            textScrollView.scrollerStyle = .overlay
            textScrollView.documentView = documentView
            stackView.addArrangedSubview(textScrollView)

            let clipView = textScrollView.contentView
            let textScrollHeight = textScrollView.heightAnchor.constraint(equalTo: documentView.heightAnchor)
            textScrollHeight.priority = AlertLayoutPriority.textHeight
            textScrollView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            pinHorizontally(textScrollView, inset: Self.horizontalInset)
            NSLayoutConstraint.activate([
                documentView.topAnchor.constraint(equalTo: clipView.topAnchor),
                documentView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
                documentView.widthAnchor.constraint(equalTo: clipView.widthAnchor),
                textStackView.topAnchor.constraint(equalTo: documentView.topAnchor),
                textStackView.leadingAnchor.constraint(equalTo: documentView.leadingAnchor),
                textStackView.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
                textStackView.bottomAnchor.constraint(equalTo: documentView.bottomAnchor),
                textScrollHeight,
            ])

            if !messageTitle.isEmpty {
                let titleLabel = makeLabel(
                    messageTitle,
                    font: .alertSystemFont(forTextStyle: .body, weight: .semibold),
                    width: labelWidth
                )
                textStackView.addArrangedSubview(titleLabel)
                titleLabel.widthAnchor.constraint(equalTo: textStackView.widthAnchor).isActive = true
            }

            let messageLabel = makeLabel(
                messageContent,
                font: .alertSystemFont(forTextStyle: .subheadline),
                width: labelWidth
            )
            messageLabel.wantsLayer = true
            messageLabel.isHidden = messageContent.isEmpty
            self.messageLabel = messageLabel
            textStackView.addArrangedSubview(messageLabel)
            messageLabel.widthAnchor.constraint(equalTo: textStackView.widthAnchor).isActive = true
            updateTextScrollViewVisibility()
        }

        private func makeLabel(_ text: String, font: NSFont, width: CGFloat) -> NSTextField {
            let label = NSTextField(wrappingLabelWithString: text)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = font
            label.textColor = .labelColor
            label.alignment = .center
            label.isSelectable = false
            label.lineBreakMode = .byWordWrapping
            label.preferredMaxLayoutWidth = width
            label.setContentCompressionResistancePriority(.required, for: .vertical)
            label.setContentCompressionResistancePriority(AlertLayoutPriority.horizontalFit, for: .horizontal)
            label.setContentHuggingPriority(AlertLayoutPriority.horizontalFit, for: .horizontal)
            return label
        }

        private func updateTextScrollViewVisibility() {
            let hasVisibleText = textStackView.arrangedSubviews.contains { !$0.isHidden }
            textScrollView.isHidden = !hasVisibleText
        }

        // MARK: Actions

        private func setupActionButtons() {
            actionPresentations = AlertActionLayoutPolicy.makePresentations(from: context.actions)
            actionButtons = actionPresentations.map { presentation in
                AlertButton(action: presentation.action, attribute: presentation.effectiveAttribute)
            }

            guard actionButtons.count == 2 else {
                for button in actionButtons {
                    stackView.addArrangedSubview(button)
                    pinHorizontally(button, inset: Self.horizontalInset)
                }
                return
            }

            // Two actions sit side by side and stack when a title wraps.
            let container = NSView()
            container.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(container)
            pinHorizontally(container, inset: Self.horizontalInset)

            let first = actionButtons[0]
            let second = actionButtons[1]
            container.addSubview(first)
            container.addSubview(second)
            let spacing = AlertActionLayoutPolicy.actionSpacing
            actionAxisConstraints[.horizontal] = [
                first.topAnchor.constraint(equalTo: container.topAnchor),
                first.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                first.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                second.topAnchor.constraint(equalTo: container.topAnchor),
                second.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                second.leadingAnchor.constraint(equalTo: first.trailingAnchor, constant: spacing),
                second.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                second.widthAnchor.constraint(equalTo: first.widthAnchor),
            ]
            actionAxisConstraints[.vertical] = [
                first.topAnchor.constraint(equalTo: container.topAnchor),
                first.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                first.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                second.topAnchor.constraint(equalTo: first.bottomAnchor, constant: spacing),
                second.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                second.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                second.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ]
            let availableWidth = Self.preferredWidth - Self.horizontalInset * 2
            applyActionAxis(AlertActionLayoutPolicy.preferredAxis(
                for: actionPresentations,
                availableWidth: availableWidth
            ))
        }

        private func updateButtonAxisIfNeeded() {
            guard actionPresentations.count == 2 else { return }
            let availableWidth = max(stackView.bounds.width - Self.horizontalInset * 2, 0)
            guard availableWidth > 0 else { return }
            applyActionAxis(AlertActionLayoutPolicy.preferredAxis(
                for: actionPresentations,
                availableWidth: availableWidth
            ))
        }

        private func applyActionAxis(_ axis: PlatformLayoutAxis) {
            guard appliedActionAxis != axis else { return }
            if let appliedActionAxis {
                NSLayoutConstraint.deactivate(actionAxisConstraints[appliedActionAxis] ?? [])
            }
            NSLayoutConstraint.activate(actionAxisConstraints[axis] ?? [])
            appliedActionAxis = axis
        }

        private func updateKeyViewLoop() {
            let views = keyViews
            for (index, keyView) in views.enumerated() {
                keyView.nextKeyView = views[(index + 1) % views.count]
            }
        }

        private func pinHorizontally(_ subview: NSView, inset: CGFloat) {
            NSLayoutConstraint.activate([
                subview.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: inset),
                subview.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -inset),
            ])
        }
    }

    /// Document view for the text scroll view, so text starts at the top.
    private final class AlertFlippedView: NSView {
        override var isFlipped: Bool {
            true
        }
    }

    /// Fills a rounded square with the configured image, like UIKit's
    /// `scaleAspectFill`.
    private final class AlertImageView: NSView {
        let image: NSImage

        init(image: NSImage) {
            self.image = image
            super.init(frame: .zero)
            wantsLayer = true
            layerContentsRedrawPolicy = .onSetNeedsDisplay
            setAccessibilityElement(false)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        override var wantsUpdateLayer: Bool {
            true
        }

        override func updateLayer() {
            super.updateLayer()
            guard let layer else { return }
            let scale = window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2
            layer.contents = image.layerContents(forContentsScale: scale)
            layer.contentsScale = scale
            layer.contentsGravity = .resizeAspectFill
            layer.cornerRadius = 12
            layer.cornerCurve = .continuous
            layer.masksToBounds = true
        }

        override func viewDidChangeBackingProperties() {
            super.viewDidChangeBackingProperties()
            needsDisplay = true
        }
    }
#endif
