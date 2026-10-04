//
//  PlatformTypes.swift
//  AlertController
//

@_exported import CoreGraphics
@_exported import Foundation

#if canImport(UIKit)
    @_exported import UIKit

    public typealias PlatformView = UIView
    public typealias PlatformViewController = UIViewController
    public typealias PlatformColor = UIColor
    public typealias PlatformImage = UIImage
    public typealias PlatformFont = UIFont

    typealias PlatformEdgeInsets = UIEdgeInsets
    typealias PlatformLayoutAxis = NSLayoutConstraint.Axis
#elseif canImport(AppKit)
    @_exported import AppKit

    public typealias PlatformView = NSView
    public typealias PlatformViewController = NSViewController
    public typealias PlatformColor = NSColor
    public typealias PlatformImage = NSImage
    public typealias PlatformFont = NSFont

    typealias PlatformEdgeInsets = NSEdgeInsets
    typealias PlatformLayoutAxis = NSLayoutConstraint.Orientation
#endif
