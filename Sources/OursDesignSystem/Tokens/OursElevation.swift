import SwiftUI

/// Elevation levels. Ours is mostly flat — elevation exists only to clarify hierarchy.
///
/// Use the lowest level that achieves clarity, avoid stacking elevated elements, and never
/// use shadow as the primary visual style.
public enum OursElevation: Sendable {
    /// Flat. Backgrounds, sections and dividers. Border only.
    case none
    /// Subtle lift for product cards, inputs and small controls.
    case small
    /// Noticeable lift for sheets, modals, dropdowns and important overlays.
    case medium

    var shadowColor: Color {
        switch self {
        case .none: .clear
        case .small: .black.opacity(0.06)
        case .medium: .black.opacity(0.10)
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .none: 0
        case .small: 8
        case .medium: 24
        }
    }

    var shadowOffsetY: CGFloat {
        switch self {
        case .none: 0
        case .small: 2
        case .medium: 8
        }
    }

    /// Levels below `medium` carry a hairline border; overlays rely on the shadow alone.
    var hasBorder: Bool {
        switch self {
        case .none, .small: true
        case .medium: false
        }
    }
}

public extension View {
    /// Applies an elevation level: its shadow, and a hairline `mist` border where the level
    /// specifies one.
    func oursElevation(_ level: OursElevation, cornerRadius: CGFloat = OursRadius.md) -> some View {
        self
            .overlay {
                if level.hasBorder {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(OursColor.mist, lineWidth: 1)
                }
            }
            .shadow(
                color: level.shadowColor,
                radius: level.shadowRadius / 2,
                x: 0,
                y: level.shadowOffsetY
            )
    }
}
