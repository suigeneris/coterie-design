import SwiftUI

/// Tone of a contextual message. §14 ranks an inline message second in the feedback
/// hierarchy — above a toast and well above a dialog — so this is the default home for
/// anything the user needs to read but not decide on.
///
/// Every tone pairs a colour with an icon: §14's don'ts include *never rely on colour alone*.
public enum OursMessageTone: Sendable, CaseIterable {
    case error
    case warning
    case info
    case success

    var foreground: Color {
        switch self {
        case .error: OursColor.error
        case .warning: OursColor.warning
        case .info: OursColor.info
        case .success: OursColor.success
        }
    }

    /// Pale enough to keep the message legible on top of it, since the foreground is a
    /// saturated semantic colour rather than `ink`.
    ///
    /// `success` sits on white rather than `sage`, which would be the obvious pairing:
    /// `success` on `sage` measures 4.26:1, under AA. The palette has no paler green, and
    /// darkening `success` to fit a decorative tint is the tail wagging the dog.
    var background: Color {
        switch self {
        case .error: OursColor.errorSurface
        case .warning: OursColor.peach
        case .info, .success: OursColor.surfaceBase
        }
    }

    /// The banner's edge. Every ground above is within 1.11:1 of cream (`errorSurface` 1.04,
    /// `peach` 1.06, white 1.11), so on the app background a borderless banner is loose text.
    /// The tone's own colour already clears 4.5:1 on cream and on its fill, so the edge is
    /// always visible and repeats the tone rather than adding a fifth colour.
    var border: Color { foreground }

    var symbol: String {
        switch self {
        case .error: "exclamationmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .info: "info.circle.fill"
        case .success: "checkmark.circle.fill"
        }
    }

    /// Prefix read before the message so the tone is not conveyed by colour alone to anyone
    /// who cannot see it.
    var accessibilityPrefix: String {
        switch self {
        case .error: "Error"
        case .warning: "Warning"
        case .info: "Information"
        case .success: "Success"
        }
    }
}

/// A contextual message sitting next to the thing it describes.
///
/// `radiusSm`, as §04 assigns alerts: a one-line banner is about 42pt tall, and `radiusMd`
/// would round it towards a pill.
///
/// Use for anything that explains a result without demanding a decision. Reach for a dialog
/// only when the user genuinely cannot continue without answering.
public struct OursMessageBanner: View {
    private let message: String
    private let tone: OursMessageTone

    public init(_ message: String, tone: OursMessageTone = .error) {
        self.message = message
        self.tone = tone
    }

    public var body: some View {
        HStack(alignment: .top, spacing: OursSpacing.xs) {
            Image(systemName: tone.symbol)
                .foregroundStyle(tone.foreground)
                .accessibilityHidden(true)
            Text(message)
                .oursTextStyle(.bodySmall)
                .foregroundStyle(tone.foreground)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(OursSpacing.sm)
        .background(tone.background)
        .clipShape(RoundedRectangle(cornerRadius: OursRadius.sm, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: OursRadius.sm, style: .continuous)
                .strokeBorder(tone.border, lineWidth: OursStroke.hairline)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tone.accessibilityPrefix). \(message)")
    }
}
