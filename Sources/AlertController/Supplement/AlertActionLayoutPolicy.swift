//
//  AlertActionLayoutPolicy.swift
//  AlertController
//
//  Created by 秋星桥 on 4/10/26.
//

import UIKit

struct PresentedAlertAction {
    let action: ActionContext.Action
    let effectiveAttribute: ActionContext.Action.Attribute
}

enum AlertActionLayoutPolicy {
    static let actionSpacing: CGFloat = 8
    static let buttonContentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    static func makePresentations(from actions: [ActionContext.Action]) -> [PresentedAlertAction] {
        let containsAccentAction = actions.contains { $0.attribute == .accent }
        return actions.enumerated().map { index, action in
            let shouldPromoteLastAction = !containsAccentAction && index == actions.index(before: actions.endIndex)
            return PresentedAlertAction(
                action: action,
                effectiveAttribute: shouldPromoteLastAction ? .accent : action.attribute
            )
        }
    }

    static func preferredAxis(
        for actions: [PresentedAlertAction],
        availableWidth: CGFloat
    ) -> NSLayoutConstraint.Axis {
        guard actions.count == 2 else {
            return .vertical
        }

        let buttonWidth = (availableWidth - actionSpacing) / 2
        let textWidth = buttonWidth - buttonContentInsets.left - buttonContentInsets.right
        guard textWidth > 0 else {
            return .vertical
        }

        let needsWrappedButton = actions.contains { action in
            let textHeight = action.action.title.boundingRect(
                with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: action.effectiveAttribute.font],
                context: nil
            ).height
            return ceil(textHeight) > ceil(action.effectiveAttribute.font.lineHeight)
        }

        return needsWrappedButton ? .vertical : .horizontal
    }
}
