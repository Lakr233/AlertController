//
//  CatalogPageID+Content.swift
//  AlertCatalog
//
//  Maps every catalog page to its view. Each page is one self-contained view
//  in Pages/<Group>/, named after its CatalogPageID case.
//

import SwiftUI

extension CatalogPageID {
    /// The page's view.
    var content: AnyView {
        switch self {
        case .basicAlert: AnyView(BasicAlertPage())
        case .singleAction: AnyView(SingleActionPage())
        case .longMessage: AnyView(LongMessagePage())
        case .manyActions: AnyView(ManyActionsPage())
        case .buttonLayout: AnyView(ButtonLayoutPage())
        case .accentPromotion: AnyView(AccentPromotionPage())
        case .attributes: AnyView(AttributesPage())
        case .dispose: AnyView(DisposePage())
        case .inputAlert: AnyView(InputAlertPage())
        case .progressUpdates: AnyView(ProgressUpdatesPage())
        case .progressMessages: AnyView(ProgressMessagesPage())
        case .configuration: AnyView(ConfigurationPage())
        case .dismissal: AnyView(DismissalPage())
        case .localization: AnyView(LocalizationPage())
        }
    }
}
