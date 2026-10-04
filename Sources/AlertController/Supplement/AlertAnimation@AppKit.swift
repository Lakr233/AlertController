//
//  AlertAnimation@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit animates with UIView spring animations, see UIView+SpringAnimation.swift.
#elseif canImport(AppKit)
    import AppKit
    import QuartzCore

    /// Core Animation building blocks for the AppKit alert transitions.
    /// Each animation only decorates the layer; callers set the model value.
    enum AlertAnimation {
        static let opacityKey = "AlertController.opacity"
        static let transformKey = "AlertController.transform"
        static let bounceKey = "AlertController.bounce"

        static var prefersReducedMotion: Bool {
            NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        }

        static func fade(
            from fromValue: Float,
            to toValue: Float,
            duration: CFTimeInterval
        ) -> CABasicAnimation {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = fromValue
            animation.toValue = toValue
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            return animation
        }

        static func springFade(from fromValue: Float, to toValue: Float) -> CASpringAnimation {
            spring(keyPath: "opacity", from: fromValue, to: toValue)
        }

        static func springScale(
            from fromScale: CGFloat,
            to toScale: CGFloat,
            in layer: CALayer
        ) -> CASpringAnimation {
            spring(
                keyPath: "transform",
                from: NSValue(caTransform3D: centeredScale(fromScale, in: layer)),
                to: NSValue(caTransform3D: centeredScale(toScale, in: layer))
            )
        }

        static func scale(
            from fromScale: CGFloat,
            to toScale: CGFloat,
            in layer: CALayer,
            duration: CFTimeInterval
        ) -> CABasicAnimation {
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: centeredScale(fromScale, in: layer))
            animation.toValue = NSValue(caTransform3D: centeredScale(toScale, in: layer))
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            return animation
        }

        /// A short press-in that tells the user the alert wants an answer.
        static func bounce(in layer: CALayer) -> CAKeyframeAnimation {
            let animation = CAKeyframeAnimation(keyPath: "transform")
            animation.values = [
                NSValue(caTransform3D: CATransform3DIdentity),
                NSValue(caTransform3D: centeredScale(0.995, in: layer)),
                NSValue(caTransform3D: CATransform3DIdentity),
            ]
            animation.keyTimes = [0, 0.17, 1]
            animation.duration = 0.3
            animation.timingFunctions = [
                CAMediaTimingFunction(name: .easeIn),
                CAMediaTimingFunction(name: .easeOut),
            ]
            return animation
        }

        /// A damping ratio of 0.8 over a 0.4 s response, close to the UIKit
        /// presentation spring.
        private static func spring(keyPath: String, from fromValue: Any, to toValue: Any) -> CASpringAnimation {
            let response: CGFloat = 0.4
            let dampingRatio: CGFloat = 0.8
            let animation = CASpringAnimation(keyPath: keyPath)
            animation.mass = 1
            animation.stiffness = pow(2 * .pi / response, 2)
            animation.damping = 4 * .pi * dampingRatio / response
            animation.fromValue = fromValue
            animation.toValue = toValue
            animation.duration = animation.settlingDuration
            return animation
        }

        /// Scales around the layer's center. AppKit puts the anchor point of
        /// a view's layer at its origin, so the transform recenters itself.
        private static func centeredScale(_ scale: CGFloat, in layer: CALayer) -> CATransform3D {
            let bounds = layer.bounds
            let offsetX = bounds.width * (0.5 - layer.anchorPoint.x)
            let offsetY = bounds.height * (0.5 - layer.anchorPoint.y)
            let toCenter = CATransform3DMakeTranslation(-offsetX, -offsetY, 0)
            let scaled = CATransform3DConcat(toCenter, CATransform3DMakeScale(scale, scale, 1))
            return CATransform3DConcat(scaled, CATransform3DMakeTranslation(offsetX, offsetY, 0))
        }
    }
#endif
