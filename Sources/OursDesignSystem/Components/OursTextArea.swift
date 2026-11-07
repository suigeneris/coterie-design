import SwiftUI

public struct OursTextArea: View {
    private let placeholder: String
    private let text: Binding<String>
    private let limit: Int
    private let state: OursFieldState

    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ placeholder: String,
        text: Binding<String>,
        limit: Int,
        state: OursFieldState = .neutral
    ) {
        self.placeholder = placeholder
        self.text = text
        self.limit = limit
        self.state = state
    }

    public nonisolated static func countLabel(text: String, limit: Int) -> String {
        "\(text.unicodeScalars.count)/\(limit)"
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: OursSpacing.xxs) {
            field

            HStack(alignment: .top, spacing: OursSpacing.xs) {
                if let message = state.message {
                    Text(message)
                        .oursTextStyle(.bodySmall)
                        .foregroundStyle(state.messageColor)
                }
                Spacer(minLength: 0)
                Text(Self.countLabel(text: text.wrappedValue, limit: limit))
                    .oursTextStyle(.caption)
                    .foregroundStyle(OursColor.stone)
                    .accessibilityLabel(
                        "\(text.wrappedValue.unicodeScalars.count) of \(limit) characters"
                    )
            }
            .padding(.horizontal, OursSpacing.xxs)
        }
        .accessibilityElement(children: .combine)
    }

    private var field: some View {
        TextField(
            "",
            text: text,
            prompt: Text(placeholder).foregroundStyle(OursColor.stone),
            axis: .vertical
        )
        .lineLimit(3...)
        .focused($isFocused)
        .oursTextStyle(.bodyLarge)
        .foregroundStyle(isEnabled ? OursColor.ink : OursColor.stone)
        .tint(OursColor.focus)
        .padding(.horizontal, OursSpacing.md)
        .padding(.vertical, OursSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .topLeading)
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
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }
}
