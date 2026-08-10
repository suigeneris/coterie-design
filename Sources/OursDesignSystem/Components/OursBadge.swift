import SwiftUI

/// Badge tone. Badges are short and semantic — `Verified`, `New`, `1/4 available`, `Sold out`.
///
/// Every tone places `ink` or `forest` on its fill: `lavender` and `yellow` are far too light
/// to carry text themselves.
public enum OursBadgeTone: Sendable {
    /// Attention — availability counts, `Popular`, `Limited`.
    case attention
    /// Feature highlight or ownership context.
    case feature
    /// Confirmed state, e.g. `Verified`.
    case success
    /// Inactive or past state, e.g. `Sold out`, `Archived`.
    case neutral

    var background: Color {
        switch self {
        case .attention: OursColor.yellow
        case .feature: OursColor.lavender
        case .success: OursColor.forest
        case .neutral: OursColor.mist
        }
    }

    var foreground: Color {
        switch self {
        case .attention, .feature: OursColor.ink
        case .success: .white
        case .neutral: OursColor.slate
        }
    }
}

/// A short semantic label.
public struct OursBadge: View {
    private let text: String
    private let tone: OursBadgeTone
    private let systemImage: String?

    public init(_ text: String, tone: OursBadgeTone = .neutral, systemImage: String? = nil) {
        self.text = text
        self.tone = tone
        self.systemImage = systemImage
    }

    public var body: some View {
        HStack(spacing: OursSpacing.xxs) {
            if let systemImage {
                Image(systemName: systemImage).imageScale(.small)
            }
            Text(text)
        }
        .oursTextStyle(.bodySmall)
        .foregroundStyle(tone.foreground)
        .padding(.horizontal, OursSpacing.sm)
        .padding(.vertical, OursSpacing.xs)
        .background(tone.background)
        .clipShape(RoundedRectangle(cornerRadius: OursRadius.xs, style: .continuous))
        // The icon is decorative; the text already carries the meaning, so state is never
        // communicated by colour or symbol alone.
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}
