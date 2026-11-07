import SwiftUI

public struct OursChip: View {
    private let title: String
    private let systemImage: String?
    private let isSelected: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        systemImage: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.action = action
    }

    public nonisolated static func background(isSelected: Bool) -> Color {
        isSelected ? OursColor.forest : OursColor.surfaceBase
    }

    public nonisolated static func foreground(isSelected: Bool) -> Color {
        isSelected ? .white : OursColor.ink
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: OursSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .imageScale(.small)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .oursTextStyle(.body)
            }
            .foregroundStyle(Self.foreground(isSelected: isSelected))
            .padding(.horizontal, OursSpacing.md)
            .frame(minHeight: OursSize.minimumTouchTarget)
            .background(Self.background(isSelected: isSelected))
            .clipShape(RoundedRectangle(cornerRadius: OursRadius.xs, style: .continuous))
            .overlay {
                if !isSelected {
                    RoundedRectangle(cornerRadius: OursRadius.xs, style: .continuous)
                        .strokeBorder(OursColor.mist, lineWidth: 1)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: OursRadius.xs, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
