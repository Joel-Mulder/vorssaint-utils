// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit

/// Guides for lining the island up with a pill camera by eye: a red outline
/// along the inner edge of the closed pill, and of the bubble beside the
/// system's pill while it shows, with thinner lines running on from each of
/// their edges, up and down from the sides and across from the top and
/// bottom. Drawn in a window of their own above the island that takes no
/// clicks, so the island works as usual beneath them.
final class NotchAlignmentGuides {
    static let outlineWidth: CGFloat = 1.5
    static let lineWidth: CGFloat = 0.5
    /// How far below the top of the display the vertical lines reach.
    static let depth: CGFloat = 140

    private var panel: NSPanel?
    private let view = GuidesView()

    static func isEnabled(in defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: DefaultsKey.notchAlignmentGuides)
    }

    /// Shows guides around `pills`, in global points with the origin at the
    /// bottom left, on `screen`; no pills hides them.
    func show(_ pills: [CGRect], on screen: CGRect, above level: NSWindow.Level) {
        guard !pills.isEmpty else { hide(); return }
        let frame = CGRect(x: screen.minX, y: screen.maxY - Self.depth, width: screen.width, height: Self.depth)
        let panel = self.panel ?? makePanel()
        panel.level = NSWindow.Level(rawValue: level.rawValue + 1)
        if panel.frame != frame { panel.setFrame(frame, display: false) }
        view.pills = pills.map { $0.offsetBy(dx: -frame.minX, dy: -frame.minY) }
        view.needsDisplay = true
        panel.orderFrontRegardless()
    }

    func hide() {
        panel?.orderOut(nil)
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        panel.sharingType = .readOnly
        panel.contentView = view
        self.panel = panel
        return panel
    }

    private final class GuidesView: NSView {
        var pills: [CGRect] = []
        override var isOpaque: Bool { false }

        override func draw(_ dirtyRect: NSRect) {
            let red = NSColor.systemRed
            for pill in pills {
                // Lines first, so the outline stays clear where they meet it.
                red.withAlphaComponent(0.7).setStroke()
                let lines = NSBezierPath()
                lines.lineWidth = NotchAlignmentGuides.lineWidth
                for x in [pill.minX, pill.maxX] {
                    lines.move(to: CGPoint(x: x, y: bounds.minY))
                    lines.line(to: CGPoint(x: x, y: bounds.maxY))
                }
                for y in [pill.minY, pill.maxY] {
                    lines.move(to: CGPoint(x: bounds.minX, y: y))
                    lines.line(to: CGPoint(x: bounds.maxX, y: y))
                }
                lines.stroke()

                // Along the inside of the edge, so the line marks where the island ends.
                let inset = NotchAlignmentGuides.outlineWidth / 2
                let edge = pill.insetBy(dx: inset, dy: inset)
                let radius = max(0, min(edge.height / 2, edge.width / 2, 28 - inset))
                let outline = NSBezierPath(roundedRect: edge, xRadius: radius, yRadius: radius)
                outline.lineWidth = NotchAlignmentGuides.outlineWidth
                red.setStroke()
                outline.stroke()
            }
        }
    }
}
