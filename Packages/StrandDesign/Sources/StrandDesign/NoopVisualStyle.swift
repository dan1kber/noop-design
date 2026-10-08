import SwiftUI

// MARK: - NOOP visual foundation
//
// These tokens describe the visual treatment used by NOOP's existing views. They deliberately
// contain no navigation, state, or domain semantics: screens keep their current hierarchy and data
// bindings, while cards, gauges, typography, and chrome share one maintainable source of truth.

public enum NoopVisualStyle {
    // Neutral, low-chroma surfaces sampled from the supplied dark-mode reference.
    public static let canvas = Color(light: "#F3F4F6", dark: "#000000")
    public static let surface = Color(light: "#FFFFFF", dark: "#131418")
    public static let surfaceTop = Color(light: "#FFFFFF", dark: "#191A1F")
    public static let surfaceBottom = Color(light: "#F4F5F7", dark: "#101114")
    public static let inset = Color(light: "#E8E9ED", dark: "#0B0C0F")

    public static let border = Color(light: "#D8DAE0", dark: "#24252B")
    public static let borderHighlight = Color(light: "#FFFFFF", dark: "#383A42")
    public static let divider = Color(light: "#E4E5E9", dark: "#222329")

    public static let primaryText = Color(light: "#17181C", dark: "#F5F5F7")
    public static let secondaryText = Color(light: "#555861", dark: "#A9ABB3")
    public static let tertiaryText = Color(light: "#7D808A", dark: "#6C6E77")

    public static let mint = Color(light: "#149A78", dark: "#E4F04A")
    public static let mintDeep = Color(light: "#0D765C", dark: "#B9C52E")
    public static let mintGlow = Color(light: "#38C99E", dark: "#EEF77A")

    public static let cardRadius: CGFloat = 30
    public static let compactRadius: CGFloat = 22
    public static let pillRadius: CGFloat = 999
    public static let pagePadding: CGFloat = 16
    public static let cardPadding: CGFloat = 16
    public static let itemGap: CGFloat = 12
    public static let sectionGap: CGFloat = 26
}

/// Shared card/panel treatment: a solid surface on iOS, gradient and soft elevation elsewhere.
/// `tint` is intentionally faint so metric identity never turns the whole card into a coloured tile.
public struct NoopPanelSurface: View {
    public var tint: Color?
    public var cornerRadius: CGFloat
    public var elevated: Bool
    public var surfaceOpacity: Double
    #if !os(iOS)
    @Environment(\.colorScheme) private var scheme
    #endif

    public init(
        tint: Color? = nil,
        cornerRadius: CGFloat = NoopVisualStyle.cardRadius,
        elevated: Bool = false,
        surfaceOpacity: Double = 1
    ) {
        self.tint = tint
        self.cornerRadius = cornerRadius
        self.elevated = elevated
        self.surfaceOpacity = surfaceOpacity
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        #if os(iOS)
        // Scrolling stacks contain many panels. Layered translucent gradients and blurred shadows
        // multiply their compositing work, so iOS uses one theme-aware fill and a thin tinted rim.
        // This changes decorative depth only; card geometry and the design-system colors stay the same.
        // W3P aura: a tinted panel keeps a dark core for its text and lets the tint glow in from the rim.
        // It is one elliptical gradient over one fill, so the compositing cost stays at two layers.
        shape
            .fill(NoopVisualStyle.surface)
            .overlay {
                if let tint {
                    shape.fill(EllipticalGradient(
                        stops: [
                            .init(color: tint.opacity(0), location: 0.42),
                            .init(color: tint.opacity(0.16), location: 0.72),
                            .init(color: tint.opacity(0.46), location: 1)
                        ],
                        center: UnitPoint(x: 0.5, y: 0.54)
                    ))
                }
            }
            .overlay(shape.strokeBorder(
                tint?.opacity(0.5) ?? NoopVisualStyle.borderHighlight.opacity(elevated ? 0.9 : 0.65),
                lineWidth: 0.8
            ))
            .opacity(surfaceOpacity)
        #else
        shape
            .fill(
                LinearGradient(
                    colors: [NoopVisualStyle.surfaceTop, NoopVisualStyle.surfaceBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                if let tint {
                    shape.fill(
                        LinearGradient(
                            colors: [tint.opacity(0.055), tint.opacity(0.012), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
            .overlay(
                shape.strokeBorder(
                    LinearGradient(
                        colors: [NoopVisualStyle.borderHighlight.opacity(0.72), NoopVisualStyle.border.opacity(0.52)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
            )
            .shadow(
                color: scheme == .dark ? .black.opacity(elevated ? 0.34 : 0.18) : .black.opacity(0.10),
                radius: elevated ? 18 : 9,
                x: 0,
                y: elevated ? 10 : 5
            )
            .opacity(surfaceOpacity)
        #endif
    }
}

/// The W3P page ground: a faint, fixed dot grid over the canvas. Drawn once as a single path, behind
/// scrolling content, so it costs nothing while the page scrolls.
public struct NoopDotGrid: View {
    @Environment(\.colorScheme) private var scheme

    public init() {}

    public var body: some View {
        Canvas { context, size in
            let step: CGFloat = 14
            var dots = Path()
            var y = step / 2
            while y < size.height {
                var x = step / 2
                while x < size.width {
                    dots.addEllipse(in: CGRect(x: x - 0.6, y: y - 0.6, width: 1.2, height: 1.2))
                    x += step
                }
                y += step
            }
            let ink: Color = scheme == .dark ? .white.opacity(0.11) : .black.opacity(0.06)
            context.fill(dots, with: .color(ink))
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Shared edge-to-edge chrome for sheet and split-view headers. Unlike a card it has no
/// rounded outline or elevation, but it uses the same top-lit surface ramp and divider token.
public struct NoopChromeSurface: View {
    public init() {}

    public var body: some View {
        LinearGradient(
            colors: [NoopVisualStyle.surfaceTop, NoopVisualStyle.surfaceBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(NoopVisualStyle.divider)
                .frame(height: 0.5)
        }
    }
}

public extension View {
    func noopPanel(
        tint: Color? = nil,
        cornerRadius: CGFloat = NoopVisualStyle.cardRadius,
        elevated: Bool = false,
        surfaceOpacity: Double = 1
    ) -> some View {
        background {
            NoopPanelSurface(
                tint: tint,
                cornerRadius: cornerRadius,
                elevated: elevated,
                surfaceOpacity: surfaceOpacity
            )
        }
    }
}
