import SwiftUI

/// Which keyboard and content treatment a field expects.
public enum OursTextFieldKind: Sendable {
    case plain
    /// Masked, with a reveal toggle.
    case secure
}

/// Resolves a field's border. Pure, so it can be tested without rendering.
///
/// Error outranks focus: a field the user is fixing should keep showing what is wrong while
/// they type in it.
public enum OursTextFieldBorder {
    public static func color(isFocused: Bool, hasError: Bool, isEnabled: Bool) -> Color {
        if hasError { return OursColor.error }
        guard isEnabled else { return OursColor.mist }
        return isFocused ? OursColor.focus : OursColor.mist
    }

    public static func width(isFocused: Bool, hasError: Bool) -> CGFloat {
        isFocused || hasError ? 2 : 1
    }
}

/// A text field in the Ours style: 56pt tall, `radiusMd`, with default, focused, filled,
/// disabled and error states, an optional leading icon and a reveal toggle when secure.
///
/// Matches `OursButton`'s radius deliberately. §04 lists inputs under both `radiusXs` and
/// `radiusMd`, but the plates draw fields and buttons at the same roundness — measured, both
/// sit at about 14% of their height — so whatever buttons use, fields use too.
///
/// Pass `errorMessage` to put the field in its error state; the message renders beneath it.
public struct OursTextField: View {
    private let placeholder: String
    private let text: Binding<String>
    private let kind: OursTextFieldKind
    private let systemImage: String?
    private let errorMessage: String?

    @FocusState private var isFocused: Bool
    @State private var isRevealed = false
    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ placeholder: String,
        text: Binding<String>,
        kind: OursTextFieldKind = .plain,
        systemImage: String? = nil,
        errorMessage: String? = nil
    ) {
        self.placeholder = placeholder
        self.text = text
        self.kind = kind
        self.systemImage = systemImage
        self.errorMessage = errorMessage
    }

    private var hasError: Bool { errorMessage != nil }

    public var body: some View {
        VStack(alignment: .leading, spacing: OursSpacing.xxs) {
            field
            if let errorMessage {
                Text(errorMessage)
                    .oursTextStyle(.bodySmall)
                    .foregroundStyle(OursColor.error)
                    .padding(.horizontal, OursSpacing.xxs)
            }
        }
        // The message is part of the field, not a sibling: announcing them separately reads
        // as two unrelated things.
        .accessibilityElement(children: .combine)
    }

    private var field: some View {
        HStack(spacing: OursSpacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(OursColor.stone)
                    .accessibilityHidden(true)
            }

            input
                .focused($isFocused)
                .oursTextStyle(.bodyLarge)
                .foregroundStyle(isEnabled ? OursColor.ink : OursColor.stone)
                .tint(OursColor.focus)

            if kind == .secure {
                revealToggle
            }
        }
        .padding(.horizontal, OursSpacing.md)
        .frame(height: OursSize.fieldHeight)
        .background(isEnabled ? OursColor.surfaceBase : OursColor.disabled)
        .clipShape(RoundedRectangle(cornerRadius: OursRadius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: OursRadius.md, style: .continuous)
                .strokeBorder(
                    OursTextFieldBorder.color(
                        isFocused: isFocused,
                        hasError: hasError,
                        isEnabled: isEnabled
                    ),
                    lineWidth: OursTextFieldBorder.width(isFocused: isFocused, hasError: hasError)
                )
        }
        // The whole container is the target, not just the glyphs inside it.
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }

    @ViewBuilder
    private var input: some View {
        let prompt = Text(placeholder).foregroundStyle(OursColor.stone)
        if kind == .secure, !isRevealed {
            SecureField("", text: text, prompt: prompt)
        } else {
            TextField("", text: text, prompt: prompt)
        }
    }

    private var revealToggle: some View {
        Button {
            isRevealed.toggle()
        } label: {
            Image(systemName: isRevealed ? "eye.slash" : "eye")
                .foregroundStyle(OursColor.stone)
                .frame(width: OursSize.minimumTouchTarget, height: OursSize.minimumTouchTarget)
                // The glyph is inset, but the tappable area stays 44pt.
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.trailing, -OursSpacing.sm)
        .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
    }
}
