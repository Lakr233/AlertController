//
//  AlertColorView@AppKit.swift
//  AlertController
//

import Foundation

#if canImport(UIKit)
// UIKit views set `backgroundColor` and resolve dynamic colors themselves.
#elseif canImport(AppKit)
    import AppKit

    /// Layer-backed view that fills, strokes and rounds itself, resolving
    /// dynamic colors against its effective appearance on every update.
    class AlertColorView: NSView {
        var fillColor: NSColor {
            didSet { needsDisplay = true }
        }

        var borderColor: NSColor? {
            didSet { needsDisplay = true }
        }

        var borderWidth: CGFloat = 0 {
            didSet { needsDisplay = true }
        }

        var cornerRadius: CGFloat = 0 {
            didSet { needsDisplay = true }
        }

        init(fillColor: NSColor = .clear) {
            self.fillColor = fillColor
            super.init(frame: .zero)
            wantsLayer = true
            layerContentsRedrawPolicy = .onSetNeedsDisplay
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        override var wantsUpdateLayer: Bool {
            true
        }

        override func updateLayer() {
            super.updateLayer()
            guard let layer else { return }
            // AppKit sets the current appearance before calling `updateLayer`,
            // so `cgColor` resolves light and dark variants correctly.
            layer.backgroundColor = fillColor.cgColor
            layer.borderColor = borderColor?.cgColor
            layer.borderWidth = borderWidth
            layer.cornerRadius = cornerRadius
            layer.cornerCurve = .continuous
        }
    }
#endif
