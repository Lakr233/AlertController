//
//  CatalogPage.swift
//  AlertCatalog
//
//  The catalog's table of contents: every page, the group it belongs to, and
//  what it shows. The app maps each page to its view in
//  `CatalogPageID+Content.swift`; this file holds only data.
//

import Foundation

/// A section of the catalog's sidebar.
nonisolated enum CatalogGroup: String, CaseIterable, Identifiable, Sendable {
    case basics
    case actions
    case input
    case progress
    case appearance
    case behavior

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .basics: "Basics"
        case .actions: "Actions"
        case .input: "Text Input"
        case .progress: "Progress"
        case .appearance: "Appearance"
        case .behavior: "Behavior"
        }
    }

    /// The pages of this group, in sidebar order.
    var pages: [CatalogPageID] {
        CatalogPageID.allCases.filter { $0.group == self }
    }
}

/// One page of the catalog. The raw value is the identifier `-page <id>` takes on the
/// command line, and the cases are listed in sidebar order.
nonisolated enum CatalogPageID: String, CaseIterable, Identifiable, Hashable, Sendable {
    // MARK: Basics

    case basicAlert = "basics.alert"
    case singleAction = "basics.singleAction"
    case longMessage = "basics.longMessage"

    // MARK: Actions

    case manyActions = "actions.many"
    case buttonLayout = "actions.layout"
    case accentPromotion = "actions.promotion"
    case attributes = "actions.attributes"
    case dispose = "actions.dispose"

    // MARK: Text Input

    case inputAlert = "input.text"

    // MARK: Progress

    case progressUpdates = "progress.updates"
    case progressMessages = "progress.messages"

    // MARK: Appearance

    case configuration = "appearance.configuration"

    // MARK: Behavior

    case dismissal = "behavior.dismissal"
    case localization = "behavior.localization"

    var id: Self {
        self
    }

    var group: CatalogGroup {
        switch self {
        case .basicAlert, .singleAction, .longMessage:
            .basics
        case .manyActions, .buttonLayout, .accentPromotion, .attributes, .dispose:
            .actions
        case .inputAlert:
            .input
        case .progressUpdates, .progressMessages:
            .progress
        case .configuration:
            .appearance
        case .dismissal, .localization:
            .behavior
        }
    }

    var title: String {
        switch self {
        case .basicAlert: "Basic Alert"
        case .singleAction: "Single Action"
        case .longMessage: "Long Message"
        case .manyActions: "Many Actions"
        case .buttonLayout: "Long Titles"
        case .accentPromotion: "Accent Promotion"
        case .attributes: "Action Attributes"
        case .dispose: "Dispose & Completion"
        case .inputAlert: "Input Alert"
        case .progressUpdates: "Live Updates"
        case .progressMessages: "Multiline Messages"
        case .configuration: "Configuration"
        case .dismissal: "Escape & Tap Around"
        case .localization: "Localization"
        }
    }

    /// One or two sentences on what the page shows, used as its header and in the
    /// sidebar's accessibility hint.
    var summary: String {
        switch self {
        case .basicAlert:
            "AlertViewController with a title, a message and two actions, set up in one closure."
        case .singleAction:
            "One action takes the full width of the card and is drawn as the accent action."
        case .longMessage:
            "A message longer than the window scrolls inside the card, and the actions stay in view below it."
        case .manyActions:
            "Any number of actions other than two are stacked vertically, in the order they were added."
        case .buttonLayout:
            "Two actions sit side by side until either title would wrap at half the card's width; then they stack."
        case .accentPromotion:
            "When no action is marked .accent, the last one is promoted and drawn as the accent action."
        case .attributes:
            "ActionContext.Action.Attribute has two cases: .normal, an outlined button, and .accent, a filled one."
        case .dispose:
            "context.dispose(_:) dismisses the alert and then runs its completion, which may be async."
        case .inputAlert:
            "AlertInputViewController asks for one line of text, prefilled or empty, and hands it back on Done."
        case .progressUpdates:
            "AlertProgressIndicatorViewController shows a spinner; progressContext.purpose(message:) changes its message while it runs."
        case .progressMessages:
            "purpose(message:) takes messages of any length; the card grows and shrinks with a crossfade."
        case .configuration:
            "AlertControllerConfiguration sets the accent colors, the image above the title, and the card's background and separator colors."
        case .dismissal:
            "By default Escape and a tap outside the card only bounce it. Each can be allowed to dismiss the alert."
        case .localization:
            "Titles, messages and action titles are String.LocalizationValue, looked up in the app's string catalog."
        }
    }

    /// An SF Symbol for the sidebar.
    var systemImage: String {
        switch self {
        case .basicAlert: "exclamationmark.bubble"
        case .singleAction: "1.circle"
        case .longMessage: "text.alignleft"
        case .manyActions: "list.bullet.rectangle"
        case .buttonLayout: "rectangle.split.2x1"
        case .accentPromotion: "star"
        case .attributes: "paintbrush"
        case .dispose: "checkmark.circle"
        case .inputAlert: "character.cursor.ibeam"
        case .progressUpdates: "hourglass"
        case .progressMessages: "text.bubble"
        case .configuration: "paintpalette"
        case .dismissal: "escape"
        case .localization: "globe"
        }
    }
}
