//
//  UIFont+Scaled.swift
//  AlertController
//

#if canImport(UIKit)
    import UIKit

    extension UIFont {
        /// System font of the given weight that follows Dynamic Type for
        /// `textStyle`. Use with `adjustsFontForContentSizeCategory = true`.
        static func scaledSystemFont(
            forTextStyle textStyle: TextStyle,
            weight: Weight = .regular
        ) -> UIFont {
            let baseTraits = UITraitCollection(preferredContentSizeCategory: .large)
            let baseSize = UIFont.preferredFont(
                forTextStyle: textStyle,
                compatibleWith: baseTraits
            ).pointSize
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(
                for: .systemFont(ofSize: baseSize, weight: weight)
            )
        }
    }
#endif
