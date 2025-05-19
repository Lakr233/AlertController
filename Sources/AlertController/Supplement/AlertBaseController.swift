//
//  AlertBaseController.swift
//  AlertTransition
//
//  Created by 秋星桥 on 1/24/25.
//

import UIKit

public typealias AlertControllerObject = UIViewController
    & UIViewControllerTransitioningDelegate

open class AlertBaseController: AlertControllerObject {
    public let dimmingView: UIView = .init()
    public let contentView: UIView = .init()
    public let contentLayoutGuide = UILayoutGuide()

    public let contentBackgroundView = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterial)
    )
    public var shouldDismissWhenTappedAround = false
    public var shouldDismissWhenEscapeKeyPressed = false

    public init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    public init(
        rootViewController: UIViewController,
        preferredWidth: CGFloat? = 550,
        preferredHeight: CGFloat? = 550
    ) {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
        addChild(rootViewController)
        rootViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rootViewController.view)
        NSLayoutConstraint.activate([
            rootViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            rootViewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            rootViewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            rootViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        rootViewController.didMove(toParent: self)
        if let preferredWidth {
            NSLayoutConstraint.activate([
                contentView.widthAnchor.constraint(equalToConstant: preferredWidth),
            ])
        }
        if let preferredHeight {
            NSLayoutConstraint.activate([
                contentView.heightAnchor.constraint(equalToConstant: preferredHeight),
            ])
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override open var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(
                title: NSLocalizedString("Close", bundle: .module, comment: ""),
                action: #selector(escapePressed), // escape
                input: "\u{1b}",
                modifierFlags: [],
                propertyList: nil
            ),
        ]
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        defer { contentView.sendSubviewToBack(contentBackgroundView) }
        defer { contentView.layoutIfNeeded() }
        defer { contentViewDidLoad() }

        dimmingView.backgroundColor = .black
        view.addSubview(dimmingView)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            dimmingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        view.addLayoutGuide(contentLayoutGuide)
        #if targetEnvironment(macCatalyst)
            NSLayoutConstraint.activate([
                contentLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
                contentLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
                contentLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
                contentLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            ])
        #else
            if #available(iOS 15.0, macCatalyst 15.0, *) /* , false */ {
                NSLayoutConstraint.activate([
                    contentLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                    contentLayoutGuide.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
                    contentLayoutGuide.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
                    contentLayoutGuide.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16),
                ])
            } else {
                NSLayoutConstraint.activate([
                    contentLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                    contentLayoutGuide.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
                    contentLayoutGuide.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
                    contentLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
                ])
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(keyboardWillShow(_:)),
                    name: UIResponder.keyboardWillShowNotification,
                    object: nil
                )
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(keyboardWillHide(_:)),
                    name: UIResponder.keyboardWillHideNotification,
                    object: nil
                )
            }
        #endif

        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: contentLayoutGuide.centerYAnchor),
        ])

        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentBackgroundView)
        NSLayoutConstraint.activate([
            contentBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentBackgroundView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            contentBackgroundView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            contentBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        dimmingView.addGestureRecognizer(tapGesture)
    }

    @objc func contentBackgroundViewTapped() {}

    open func contentViewDidLoad() {}

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentViewLayout(in: contentView.bounds)
    }

    open func contentViewLayout(in bounds: CGRect) {
        _ = bounds
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardHeightValue = keyboardRect?.height ?? 0
        let keyboardHeight = keyboardHeightValue > 0 ? keyboardHeightValue : 0
        let animation = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        UIView.animate(
            withDuration: animationDuration ?? 0.25,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: animation ?? 0)
        ) {
            // because we are at the center of the screen, so dividing by 2
            self.contentLayoutGuide.owningView?.bounds.origin.y += keyboardHeight / 2
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        let animation = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        UIView.animate(
            withDuration: animationDuration ?? 0.25,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: animation ?? 0)
        ) {
            self.contentLayoutGuide.owningView?.bounds.origin.y = 0
            self.view.layoutIfNeeded()
        }
    }

    func contentViewBounce() {
        UIView.animate(withDuration: 0.05) {
            self.contentView.transform = CGAffineTransform(scaleX: 0.995, y: 0.995)
        } completion: { _ in
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 0.8
            ) { self.contentView.transform = .identity }
        }
    }

    @objc open func dimmingViewTapped() {
        if shouldDismissWhenTappedAround {
            presentingViewController?.dismiss(animated: true)
        } else {
            contentViewBounce()
        }
    }

    @objc open func escapePressed() {
        if shouldDismissWhenEscapeKeyPressed {
            presentingViewController?.dismiss(animated: true)
        } else {
            contentViewBounce()
        }
    }

    open func animationController(
        forPresented _: UIViewController,
        presenting _: UIViewController,
        source _: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        AlertTransitionAnimator(isPresenting: true)
    }

    open func animationController(forDismissed _: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        AlertTransitionAnimator(isPresenting: false)
    }

    open func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source _: UIViewController
    ) -> UIPresentationController? {
        AlertPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}
