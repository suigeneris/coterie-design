import SwiftUI

public enum OursChipSize: Sendable {
    case regular
    case large
    case tile

    var height: CGFloat {
        switch self {
        case .regular: OursSize.minimumTouchTarget
        case .large: OursSize.chipLarge
        case .tile: OursSize.chipTile
        }
    }

    var textStyle: OursTextStyle {
        switch self {
        case .regular: .body
        case .large: .h3
        case .tile: .button
        }
    }

    var cornerRadius: CGFloat { self == .tile ? OursRadius.md : OursRadius.xs }

    var fillsWidth: Bool { self != .regular }

    var stacksSymbol: Bool { self == .tile }
}

public struct OursChip: View {
    private let title: String
    private let systemImage: String?
    private let isSelected: Bool
    private let size: OursChipSize
    private let action: () -> Void

    public init(
        _ title: String,
        systemImage: String? = nil,
        isSelected: Bool,
        size: OursChipSize = .regular,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.size = size
        self.action = action
    }

    public nonisolated static func background(isSelected: Bool) -> Color {
        isSelected ? OursColor.forest : OursColor.surfaceBase
    }

    public nonisolated static func foreground(isSelected: Bool) -> Color {
        isSelected ? .white : OursColor.ink
    }

    /// `outline`, not `mist`: a white chip on cream is 1.11:1, so the border is what tells
    /// someone the chip is there to tap. A selected chip's `forest` fill is its own edge.
    public nonisolated static func border(isSelected: Bool) -> Color? {
        isSelected ? nil : OursColor.outline
    }

    public var body: some View {
        Button(action: action) {
            content
                .foregroundStyle(Self.foreground(isSelected: isSelected))
                .padding(.horizontal, OursSpacing.md)
                .frame(maxWidth: size.fillsWidth ? .infinity : nil, minHeight: size.height)
                .background(Self.background(isSelected: isSelected))
                .clipShape(shape)
                .overlay {
                    if let border = Self.border(isSelected: isSelected) {
                        shape.strokeBorder(border, lineWidth: OursStroke.hairline)
                    }
                }
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
    }

    @ViewBuilder
    private var content: some View {
        if size.stacksSymbol {
            VStack(spacing: OursSpacing.sm) {
                symbol
                label
            }
        } else {
            HStack(spacing: OursSpacing.xs) {
                symbol
                label
            }
        }
    }

    @ViewBuilder
    private var symbol: some View {
        if let systemImage {
            let image = Image(systemName: systemImage)
            Group {
                if size.stacksSymbol {
                    image.font(.system(size: OursIconSize.lg))
                } else {
                    image.imageScale(.small)
                }
            }
            .accessibilityHidden(true)
        }
    }

    private var label: some View {
        Text(title)
            .oursTextStyle(size.textStyle)
    }
}
