import SwiftUI

/// Button hierarchy. Avoid more than one `.primary` in the same decision group.
public enum OursButtonKind: Sendable {
    /// The main action on a screen.
    case primary
    /// Important, but not the main action.
    case secondary
    /// Optional actions and links. No filled container.
    case tertiary
    /// Irreversible or removing actions.
    case destructive
}

/// A button in the Ours style: 56pt tall, 16pt radius, Inter Semibold 16pt, with default,
/// pressed, disabled and loading states.
public struct OursButton: View {
    private let title: String
    private let kind: OursButtonKind
    private let isLoading: Bool
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        _ title: String,
        kind: OursButtonKind = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.kind = kind
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Text(title).opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView().tint(foreground)
                }
            }
            .oursTextStyle(.button)
            .frame(maxWidth: kind == .tertiary ? nil : .infinity)
            .frame(height: kind == .tertiary ? OursSize.minimumTouchTarget : OursSize.buttonHeight)
            .padding(.horizontal, kind == .tertiary ? 0 : OursSize.buttonHorizontalPadding)
        }
        .buttonStyle(OursButtonStyle(kind: kind, isEnabled: isEnabled, reduceMotion: reduceMotion))
        .disabled(isLoading || !isEnabled)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(title)
        .accessibilityValue(isLoading ? Text("Loading") : Text(""))
    }

    private var foreground: Color {
        switch kind {
        case .primary: .white
        case .secondary, .tertiary: OursColor.forest
        case .destructive: OursColor.error
        }
    }
}

private struct OursButtonStyle: ButtonStyle {
    let kind: OursButtonKind
    let isEnabled: Bool
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground(pressed: configuration.isPressed))
            .background(background(pressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: OursRadius.md, style: .continuous))
            .overlay {
                if kind == .secondary {
                    RoundedRectangle(cornerRadius: OursRadius.md, style: .continuous)
                        .strokeBorder(
                            isEnabled ? OursColor.forest : OursColor.stone,
                            lineWidth: configuration.isPressed ? 2 : 1
                        )
                }
            }
            .scaleEffect(configuration.isPressed && !reduceMotion ? OursMotion.pressedScale : 1)
            .animation(
                OursMotion.respectingReduceMotion(OursMotion.quickEaseOut, reduceMotion: reduceMotion),
                value: configuration.isPressed
            )
    }

    private func foreground(pressed: Bool) -> Color {
        guard isEnabled else { return OursColor.stone }
        switch kind {
        case .primary: return .white
        case .secondary, .tertiary: return OursColor.forest
        case .destructive: return pressed ? .white : OursColor.error
        }
    }

    private func background(pressed: Bool) -> Color {
        guard isEnabled else {
            return kind == .primary || kind == .destructive ? OursColor.disabled : .clear
        }
        switch kind {
        case .primary: return pressed ? OursColor.ink : OursColor.forest
        case .secondary, .tertiary: return .clear
        case .destructive: return pressed ? OursColor.error : OursColor.errorSurface
        }
    }
}
