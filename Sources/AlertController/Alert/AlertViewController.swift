//
//  Created by ktiays on 2024/11/27.
//  Copyright (c) 2024 ktiays. All rights reserved.
//

import UIKit

open class AlertViewController: AlertBaseController {
    let contentViewController: UIViewController

    public convenience init(
        title: String = "",
        message: String = "",
        setupActions: @escaping (ActionContext) -> Void
    ) {
        let controller = AlertContentController(
            title: title,
            message: message,
            setupActions: setupActions
        )
        self.init(contentViewController: controller)
    }

    public required init(contentViewController: UIViewController) {
        self.contentViewController = contentViewController
        super.init(
            rootViewController: contentViewController,
            preferredWidth: 350,
            preferredHeight: nil
        )
        transitioningDelegate = self
        modalPresentationStyle = .custom
        shouldDismissWhenTappedAround = false
        shouldDismissWhenEscapeKeyPressed = false
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        contentView.layer.cornerRadius = 20
    }

    override open func contentViewDidLoad() {
        super.contentViewDidLoad()
        addChild(contentViewController)
        contentView.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)
        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentViewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            contentViewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
