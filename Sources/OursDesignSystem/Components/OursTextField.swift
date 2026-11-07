import SwiftUI

/// Which keyboard and content treatment a field expects.
public enum OursTextFieldKind: Sendable {
    case plain
    /// Masked, with a reveal toggle.
    case secure
}

/// What a field is currently saying about its contents.
public enum OursFieldState: Equatable, Sendable {
    case neutral
    /// Something is wrong, with the reason.
    case error(String)
    /// Resolved, with an optional short confirmation.
    case success(String? = nil)

    var message: String? {
        switch self {
        case .neutral: nil
        case .error(let text): text
        case .success(let text): text
        }
    }

    var messageColor: Color {
        switch self {
        case .error: OursColor.error
        case .success: OursColor.success
        case .neutral: OursColor.stone
        }
    }
}

/// Resolves a field's border. Pure, so it can be tested without rendering.
///
/// Both states outrank focus. A field the user is fixing must keep showing what is wrong
/// while they type in it, and the moment it comes right they need to see that — which is
/// exactly while it is still focused.
public enum OursTextFieldBorder {
    public static func color(state: OursFieldState, isFocused: Bool, isEnabled: Bool) -> Color {
        guard isEnabled else { return OursColor.mist }
        switch state {
        case .error: return OursColor.error
        case .success: return OursColor.success
        case .neutral: return isFocused ? OursColor.focus : OursColor.mist
        }
    }

    public static func width(state: OursFieldState, isFocused: Bool) -> CGFloat {
        state == .neutral && !isFocused ? 1 : 2
    }
}

/// A text field in the Ours style: 56pt tall, `radiusMd`, with default, focused, filled,
/// disabled and error states, an optional leading icon and a reveal toggle when secure.
///
/// Matches `OursButton`'s radius deliberately. §04 lists inputs under both `radiusXs` and
/// `radiusMd`, but the plates draw fields and buttons at the same roundness — measured, both
/// sit at about 14% of their height — so whatever buttons use, fields use too.
///
/// Pass `state` to put the field in its error or success state; the message renders beneath.
public struct OursTextField: View {
    private let placeholder: String
    private let text: Binding<String>
    private let kind: OursTextFieldKind
    private let systemImage: String?
    private let state: OursFieldState

    @FocusState private var isFocused: Bool
    @State private var isRevealed = false
    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ placeholder: String,
        text: Binding<String>,
        kind: OursTextFieldKind = .plain,
        systemImage: String? = nil,
        state: OursFieldState = .neutral
    ) {
        self.placeholder = placeholder
        self.text = text
        self.kind = kind
        self.systemImage = systemImage
        self.state = state
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: OursSpacing.xxs) {
            field
            if let message = state.message {
                Text(message)
                    .oursTextStyle(.bodySmall)
                    .foregroundStyle(state.messageColor)
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

            if case .success = state {
                // Ahead of the reveal toggle rather than replacing it: a secure field still
                // needs its toggle, and the tick is the smaller of the two claims on the slot.
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(OursColor.success)
                    .accessibilityHidden(true)
            }

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
                        state: state,
                        isFocused: isFocused,
                        isEnabled: isEnabled
                    ),
                    lineWidth: OursTextFieldBorder.width(state: state, isFocused: isFocused)
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
