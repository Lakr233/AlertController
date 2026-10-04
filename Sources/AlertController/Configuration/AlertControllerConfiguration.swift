//
//  AlertControllerConfiguration.swift
//  AlertController
//
//  Created by 秋星桥 on 1/30/25.
//

import Foundation

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

@MainActor
public enum AlertControllerConfiguration {
    public static var alertImage: PlatformImage?
    public static var accentColor: PlatformColor = .red
    public static var accentForegroundColor: PlatformColor = .white
    public static var separatorColor: PlatformColor = defaultSeparatorColor
    public static var backgroundColor: PlatformColor = defaultBackgroundColor

    public static var module: Bundle = .module
}

private extension AlertControllerConfiguration {
    #if canImport(UIKit)
        static var defaultSeparatorColor: PlatformColor {
            .separator
        }

        static var defaultBackgroundColor: PlatformColor {
            .systemBackground
        }
    #elseif canImport(AppKit)
        static var defaultSeparatorColor: PlatformColor {
            .separatorColor
        }

        static var defaultBackgroundColor: PlatformColor {
            .windowBackgroundColor
        }
    #endif
}
