//
//  AlertContentController.swift
//  AlertController
//
//  Created by 秋星桥 on 2/22/25.
//

import UIKit

class AlertContentController: UIViewController {
    let context: ActionContext = .init()

    let messageTitle: String
    let messageContent: String
    let stackView = UIStackView()

    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))

    init(
        title: String = "",
        message: String = "",
        setupActions: @escaping (ActionContext) -> Void
    ) {
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
        stackView.distribution = .equalSpacing
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
            stackView.addArrangedSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16),
            ])
            let heightConstraint = titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 80)
            heightConstraint.priority = .required
            NSLayoutConstraint.activate([heightConstraint])
        }

        if !messageContent.isEmpty {
            let messageLabel = UILabel()
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.text = messageContent
            messageLabel.font = .systemFont(
                ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize
            )
            messageLabel.textColor = .label
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            stackView.addArrangedSubview(messageLabel)
            NSLayoutConstraint.activate([
                messageLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
                messageLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16),
            ])
            let heightConstraint = messageLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 300)
            heightConstraint.priority = .required
            NSLayoutConstraint.activate([heightConstraint])
        }

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

        switch actions.count {
        case 2:
            let horizonStack = UIStackView()
            horizonStack.axis = .horizontal
            horizonStack.spacing = 8
            horizonStack.distribution = .fillEqually
            horizonStack.alignment = .center
            horizonStack.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(horizonStack)
            horizonStack.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).isActive = true
            horizonStack.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16).isActive = true
            for action in actions {
                let button = AlertButton(action: action)
                horizonStack.addArrangedSubview(button)
            }
        default:
            for action in actions {
                let button = AlertButton(action: action)
                stackView.addArrangedSubview(button)
                button.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).isActive = true
                button.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16).isActive = true
            }
        }
    }
}
