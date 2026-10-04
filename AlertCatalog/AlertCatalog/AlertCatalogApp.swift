//
//  AlertCatalogApp.swift
//  AlertCatalog
//

import SwiftUI

@main
struct AlertCatalogApp: App {
    @State private var appearance = AlertAppearance()

    var body: some Scene {
        WindowGroup {
            CatalogRootView()
                .environment(appearance)
        }
        #if os(macOS) || targetEnvironment(macCatalyst)
        .windowResizability(.contentMinSize)
        #endif
    }
}
