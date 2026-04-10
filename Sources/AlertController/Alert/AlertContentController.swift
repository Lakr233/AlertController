//
//  AlertContentController.swift
//  AlertController
//
//  Created by 秋星桥 on 2/22/25.
//

import GlyphixTextFx
import UIKit

class AlertContentController: UIViewController {
    let context: ActionContext
    private(set) var messageLabel: GlyphixTextLabel?

    let messageTitle: String
    let messageContent: String
    let stackView = UIStackView()

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
        let applyChanges = { [self] in
            messageLabel?.text = message
            messageLabel?.isHidden = message.isEmpty
        }

        guard animated, isViewLoaded else {
            applyChanges()
            return
        }

        if let alertController = parent as? AlertBaseController {
            alertController.animateContentSizeChange {
                applyChanges()
            }
        } else {
            applyChanges()
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

        if !messageTitle.isEmpty {
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = messageTitle
            titleLabel.font = .systemFont(
                ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize,
                weight: .semibold
            )
            titleLabel.textColor = .label
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0
            titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            stackView.addArrangedSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16),
            ])
            let heightConstraint = titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 80)
            heightConstraint.priority = .required
            NSLayoutConstraint.activate([heightConstraint])
        }

        let messageLabel = GlyphixTextLabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = messageContent
        messageLabel.font = .systemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize
        )
        messageLabel.textColor = .label
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.isBlurEffectEnabled = false
        messageLabel.clipsToBounds = false
        messageLabel.layer.masksToBounds = false
        messageLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        messageLabel.isHidden = messageContent.isEmpty
        self.messageLabel = messageLabel
        stackView.addArrangedSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16),
        ])
        let heightConstraint = messageLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 300)
        heightConstraint.priority = .required
        NSLayoutConstraint.activate([heightConstraint])

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
