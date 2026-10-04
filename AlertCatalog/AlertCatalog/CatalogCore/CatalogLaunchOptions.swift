//
//  CatalogLaunchOptions.swift
//  AlertCatalog
//
//  The command-line options scripted runs and screenshots use:
//
//    -page <id>          open a page directly, by its CatalogPageID raw value
//    -autoPresent YES    run the page's first demo once the window is up
//

import Foundation

/// The options the app was launched with.
nonisolated struct CatalogLaunchOptions: Sendable {
    /// The page to open at launch.
    var page: CatalogPageID?
    /// Whether the opened page presents its first demo by itself.
    var isAutoPresenting = false

    /// The options of this process.
    static let current = CatalogLaunchOptions(arguments: ProcessInfo.processInfo.arguments)

    /// Reads `-name value` pairs from `arguments`, skipping the executable path and
    /// anything it does not know. A later value for the same name wins.
    init(arguments: [String]) {
        var values: [String: String] = [:]
        var index = arguments.startIndex
        while index < arguments.endIndex {
            let argument = arguments[index]
            let next = arguments.index(after: index)
            guard argument.hasPrefix("-"), next < arguments.endIndex else {
                index = next
                continue
            }
            values[String(argument.dropFirst())] = arguments[next]
            index = arguments.index(after: next)
        }

        page = values["page"].flatMap(CatalogPageID.init(rawValue:))
        isAutoPresenting = values["autoPresent"].map(Self.isTrue) ?? false
    }

    /// Reads a Boolean the way `UserDefaults` reads one from the command line.
    private static func isTrue(_ value: String) -> Bool {
        switch value.lowercased() {
        case "yes", "true", "1": true
        default: false
        }
    }
}
