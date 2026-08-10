import SwiftUI

/// The Ours type scale.
///
/// Instrument Serif carries headlines and editorial moments; Inter carries everything
/// functional. The serif's impact comes from its contrast with Inter — use it selectively.
///
/// Every style scales with Dynamic Type via `relativeTo:`.
public enum OursTextStyle: CaseIterable, Sendable {
    /// Instrument Serif Regular 40/48 — hero headlines. May grow to 48pt for onboarding.
    case display
    /// Instrument Serif Regular 32/40 — page and section titles.
    case h1
    /// Instrument Serif Regular 24/32 — sub-section titles.
    case h2
    /// Inter Semibold 20/28 — card titles and strong labels.
    case h3
    /// Inter Regular 17/24 — prominent body.
    case bodyLarge
    /// Inter Regular 15/22 — default body.
    case body
    /// Inter Regular 13/18 — supporting text and labels.
    case bodySmall
    /// Inter Regular 11/16 — captions and metadata.
    case caption
    /// Inter Semibold 16 — button labels.
    case button

    var size: CGFloat {
        switch self {
        case .display: 40
        case .h1: 32
        case .h2: 24
        case .h3: 20
        case .bodyLarge: 17
        case .button: 16
        case .body: 15
        case .bodySmall: 13
        case .caption: 11
        }
    }

    /// Absolute line height from the plate. `nil` where the system does not specify one.
    var lineHeight: CGFloat? {
        switch self {
        case .display: 48
        case .h1: 40
        case .h2: 32
        case .h3: 28
        case .bodyLarge: 24
        case .body: 22
        case .bodySmall: 18
        case .caption: 16
        case .button: nil
        }
    }

    var fontName: OursFontName {
        switch self {
        case .display, .h1, .h2: .instrumentSerifRegular
        case .h3, .button: .interSemiBold
        case .bodyLarge, .body, .bodySmall, .caption: .interRegular
        }
    }

    /// The system style each token scales against, so Dynamic Type behaves sensibly.
    var relativeTo: Font.TextStyle {
        switch self {
        case .display: .largeTitle
        case .h1: .title
        case .h2: .title2
        case .h3: .title3
        case .bodyLarge: .body
        case .button: .body
        case .body: .callout
        case .bodySmall: .footnote
        case .caption: .caption2
        }
    }

    /// Additional spacing between lines needed to reach the specified line height.
    var lineSpacing: CGFloat {
        guard let lineHeight else { return 0 }
        return max(0, lineHeight - size)
    }
}

public extension Font {
    /// The font for an Ours text style, scaled by Dynamic Type.
    static func ours(_ style: OursTextStyle) -> Font {
        OursFonts.registerIfNeeded()
        return .custom(style.fontName.rawValue, size: style.size, relativeTo: style.relativeTo)
    }
}

public extension View {
    /// Applies an Ours text style, including its specified line height.
    func oursTextStyle(_ style: OursTextStyle) -> some View {
        font(.ours(style)).lineSpacing(style.lineSpacing)
    }
}
