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

// MARK: - Colour resolution

extension OursButtonKind {
    /// Resolves the label colour. Pure, so it can be tested without rendering.
    ///
    /// A disabled button always looks disabled — an override never applies, because a caller
    /// tinting a label should not be able to make an unusable control look usable.
    func labelColor(pressed: Bool, isEnabled: Bool, override: Color?) -> Color {
        guard isEnabled else { return OursColor.stone }
        if let override { return override }
        switch self {
        case .primary: return .white
        case .secondary, .tertiary: return OursColor.forest
        case .destructive: return pressed ? .white : OursColor.error
        }
    }

    func backgroundColor(pressed: Bool, isEnabled: Bool) -> Color {
        guard isEnabled else {
            return self == .primary || self == .destructive ? OursColor.disabled : .clear
        }
        switch self {
        case .primary: return pressed ? OursColor.ink : OursColor.forest
        case .secondary, .tertiary: return .clear
        case .destructive: return pressed ? OursColor.error : OursColor.errorSurface
        }
    }

    var isFullWidth: Bool { self != .tertiary }
}

// MARK: - Label colour override

private struct OursButtonLabelColorKey: EnvironmentKey {
    static let defaultValue: Color?
    = nil
}

public extension EnvironmentValues {
    /// Overrides the label colour of any `OursButton` below this point.
    var oursButtonLabelColor: Color? {
        get { self[OursButtonLabelColorKey.self] }
        set { self[OursButtonLabelColorKey.self] = newValue }
    }
}

public extension View {
    /// Sets the label colour for `OursButton`s in this subtree.
    ///
    /// **`.foregroundStyle` does not work on `OursButton`.** The button's `ButtonStyle` sets
    /// the label colour on its own content, and a modifier applied closer to the content
    /// always wins — so an outer `.foregroundStyle` is silently ignored. Use this instead.
    ///
    /// Disabled buttons ignore the override so they still read as disabled.
    func oursButtonLabelColor(_ color: Color?) -> some View {
        environment(\.oursButtonLabelColor, color)
    }
}

// MARK: - Button

/// A button in the Ours style: 56pt tall, 16pt radius, Inter Semibold 16pt, with default,
/// pressed, disabled and loading states.
public struct OursButton: View {
    private let title: String
    private let kind: OursButtonKind
    private let systemImage: String?
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        kind: OursButtonKind = .primary,
        systemImage: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.kind = kind
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: OursSpacing.xs) {
                if let systemImage {
                    // Decorative: the label already says what the button does.
                    Image(systemName: systemImage)
                        .imageScale(.medium)
                        .accessibilityHidden(true)
                }
                Text(title)
            }
        }
        .buttonStyle(OursButtonStyle(kind: kind, isLoading: isLoading))
        .disabled(isLoading)
        .accessibilityLabel(title)
        .accessibilityValue(isLoading ? Text("Loading") : Text(""))
    }
}

private struct OursButtonStyle: ButtonStyle {
    let kind: OursButtonKind
    let isLoading: Bool

    func makeBody(configuration: Configuration) -> some View {
        // A nested View is required so the style can read the environment: ButtonStyle is
        // not a View, so @Environment cannot be used in makeBody directly.
        OursButtonBody(configuration: configuration, kind: kind, isLoading: isLoading)
    }
}

private struct OursButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: OursButtonKind
    let isLoading: Bool

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.oursButtonLabelColor) private var labelColorOverride

    private var labelColor: Color {
        kind.labelColor(
            pressed: configuration.isPressed,
            isEnabled: isEnabled,
            override: labelColorOverride
        )
    }

    var body: some View {
        ZStack {
            configuration.label.opacity(isLoading ? 0 : 1)
            if isLoading {
                ProgressView().tint(labelColor)
            }
        }
        .oursTextStyle(.button)
        .foregroundStyle(labelColor)
        .frame(maxWidth: kind.isFullWidth ? .infinity : nil)
        .frame(height: kind.isFullWidth ? OursSize.buttonHeight : OursSize.minimumTouchTarget)
        .padding(.horizontal, kind.isFullWidth ? OursSize.buttonHorizontalPadding : 0)
        .background(kind.backgroundColor(pressed: configuration.isPressed, isEnabled: isEnabled))
        .clipShape(RoundedRectangle(cornerRadius: OursRadius.md, style: .continuous))
        .overlay {
            if kind == .secondary {
                RoundedRectangle(cornerRadius: OursRadius.md, style: .continuous)
                    .strokeBorder(
                        isEnabled ? OursColor.forest : OursColor.stone,
                        lineWidth: configuration.isPressed ? OursStroke.strong : OursStroke.hairline
                    )
            }
        }
        .scaleEffect(configuration.isPressed && !reduceMotion ? OursMotion.pressedScale : 1)
        .animation(
            OursMotion.respectingReduceMotion(OursMotion.quickEaseOut, reduceMotion: reduceMotion),
            value: configuration.isPressed
        )
    }
}
