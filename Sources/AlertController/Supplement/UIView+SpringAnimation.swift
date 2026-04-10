//
//  UIView+SpringAnimation.swift
//  AlertController
//
//  Created by 秋星桥 on 4/10/26.
//

import UIKit

extension UIView {
    static func springAnimate(
        duration: TimeInterval = 0.5,
        dampingRatio: CGFloat = 1.0,
        initialVelocity: CGFloat = 1.0,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        let timingParameters = UISpringTimingParameters(
            dampingRatio: dampingRatio,
            initialVelocity: .init(dx: initialVelocity, dy: initialVelocity)
        )
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
        animator.addAnimations(animations)
        if let completion {
            animator.addCompletion { position in
                completion(position == .end)
            }
        }
        animator.startAnimation()
    }
}
