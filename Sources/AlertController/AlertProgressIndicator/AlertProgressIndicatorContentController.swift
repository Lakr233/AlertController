//
//  AlertProgressIndicatorContentController.swift
//  AlertController
//
//  Created by 秋星桥 on 2/22/25.
//

import UIKit

class AlertProgressIndicatorContentController: AlertContentController {
    let progressContext = ProgressContext()

    init(
        title: String = "",
        message: String = "",
        setupActions: @escaping (ActionContext) -> Void
    ) {
        super.init(
            title: title,
            message: message,
            context: progressContext,
            setupActions: setupActions
        )

        let progressIndicatorView = ProgressIndicator()
        customViews.append(HorizontalSeprator())
        customViews.append(progressIndicatorView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        progressContext.messageLabel = messageLabel
        progressContext.contentController = self
        messageLabel?.numberOfLines = 0
        messageLabel?.lineBreakMode = .byWordWrapping
    }
}

class ProgressIndicator: UIView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.topAnchor.constraint(equalTo: topAnchor),
            indicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            indicator.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        indicator.startAnimating()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
