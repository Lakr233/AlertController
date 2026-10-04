//
//  AlertContentController.swift
//  AlertController
//
//  Created by 秋星桥 on 2/22/25.
//

import UIKit

class AlertContentController: UIViewController {
    let context: ActionContext
    private(set) var messageLabel: UILabel?

    let messageTitle: String
    let messageContent: String
    let stackView = UIStackView()
    private let textScrollView = UIScrollView()
    private let textStackView = UIStackView()

    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private var actionStackView: UIStackView?
    private var actionPresentations = [PresentedAlertAction]()
    private var appliedActionAxis: NSLayoutConstraint.Axis?

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

    var customViews: [UIView] = []

    func updateMessage(_ message: String, animated: Bool) {
        guard animated, isViewLoaded, let messageLabel else {
            messageLabel?.text = message
            messageLabel?.isHidden = message.isEmpty
            updateTextScrollViewVisibility()
            return
        }

        let applyText = {
            UIView.transition(
                with: messageLabel,
                duration: 0.25,
                options: .transitionCrossDissolve
            ) {
                messageLabel.text = message
                messageLabel.isHidden = message.isEmpty
                self.updateTextScrollViewVisibility()
            }
        }

        if let alertController = parent as? AlertBaseController {
            alertController.animateContentSizeChange {
                applyText()
            }
        } else {
            applyText()
            UIView.springAnimate(
                duration: 0.5,
                dampingRatio: 1.0,
                initialVelocity: 1.0
            ) {
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AlertControllerConfiguration.backgroundColor.withAlphaComponent(0.5)

        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = context.spacing
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: context.spacing),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -context.spacing),
        ])

        if let image = AlertControllerConfiguration.alertImage {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 12
            imageView.layer.cornerCurve = .continuous
            imageView.layer.masksToBounds = true
            imageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
            stackView.addArrangedSubview(imageView)
        }

        // Title and message scroll when they do not fit, so the actions
        // below always stay visible.
        textStackView.axis = .vertical
        textStackView.spacing = context.spacing
        textStackView.alignment = .fill
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textScrollView.translatesAutoresizingMaskIntoConstraints = false
        textScrollView.showsHorizontalScrollIndicator = false
        textScrollView.addSubview(textStackView)
        stackView.addArrangedSubview(textScrollView)
        let textScrollHeight = textScrollView.heightAnchor.constraint(equalTo: textStackView.heightAnchor)
        textScrollHeight.priority = .defaultHigh - 1
        textScrollView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        NSLayoutConstraint.activate([
            textScrollView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            textScrollView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16),
            textStackView.topAnchor.constraint(equalTo: textScrollView.contentLayoutGuide.topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: textScrollView.contentLayoutGuide.leadingAnchor),
            textStackView.trailingAnchor.constraint(equalTo: textScrollView.contentLayoutGuide.trailingAnchor),
            textStackView.bottomAnchor.constraint(equalTo: textScrollView.contentLayoutGuide.bottomAnchor),
            textStackView.widthAnchor.constraint(equalTo: textScrollView.frameLayoutGuide.widthAnchor),
            textScrollHeight,
        ])

        if !messageTitle.isEmpty {
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = messageTitle
            titleLabel.font = .scaledSystemFont(forTextStyle: .body, weight: .semibold)
            titleLabel.adjustsFontForContentSizeCategory = true
            titleLabel.textColor = .label
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0
            titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            textStackView.addArrangedSubview(titleLabel)
        }

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = messageContent
        messageLabel.font = .scaledSystemFont(forTextStyle: .footnote)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = .label
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        messageLabel.isHidden = messageContent.isEmpty
        self.messageLabel = messageLabel
        textStackView.addArrangedSubview(messageLabel)
        updateTextScrollViewVisibility()

        for customView in customViews {
            stackView.addArrangedSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            var spacing: CGFloat = 16
            if customView is HorizontalSeprator {
                spacing = 0
            }
            customView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: spacing).isActive = true
            customView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -spacing).isActive = true
        }

        let actions = context.actions
        actionPresentations = AlertActionLayoutPolicy.makePresentations(from: actions)

        switch actions.count {
        case 2:
            let actionStackView = UIStackView()
            actionStackView.spacing = AlertActionLayoutPolicy.actionSpacing
            actionStackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(actionStackView)
            actionStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).isActive = true
            actionStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16).isActive = true
            for action in actionPresentations {
                let button = AlertButton(
                    action: action.action,
                    attribute: action.effectiveAttribute
                )
                actionStackView.addArrangedSubview(button)
            }
            self.actionStackView = actionStackView
        default:
            for action in actionPresentations {
                let button = AlertButton(
                    action: action.action,
                    attribute: action.effectiveAttribute
                )
                stackView.addArrangedSubview(button)
                button.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).isActive = true
                button.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16).isActive = true
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let messageLabel {
            let width = max(stackView.bounds.width - 32, 0)
            if width > 0, messageLabel.preferredMaxLayoutWidth != width {
                messageLabel.preferredMaxLayoutWidth = width
            }
        }

        updateButtonAxisIfNeeded()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.preferredContentSizeCategory
            != traitCollection.preferredContentSizeCategory
        else { return }
        appliedActionAxis = nil
        view.setNeedsLayout()
    }

    private func updateTextScrollViewVisibility() {
        let hasVisibleText = textStackView.arrangedSubviews.contains { !$0.isHidden }
        textScrollView.isHidden = !hasVisibleText
    }

    private func updateButtonAxisIfNeeded() {
        guard let actionStackView, actionPresentations.count == 2 else {
            return
        }

        let availableWidth = max(stackView.bounds.width - 32, 0)
        let axis = AlertActionLayoutPolicy.preferredAxis(
            for: actionPresentations,
            availableWidth: availableWidth
        )
        guard appliedActionAxis != axis else {
            return
        }

        appliedActionAxis = axis
        actionStackView.axis = axis
        actionStackView.alignment = .fill
        actionStackView.distribution = axis == .horizontal ? .fillEqually : .fill
    }
}
