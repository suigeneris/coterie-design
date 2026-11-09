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

    var symbolSize: CGFloat { OursIconSize.lg }
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

    var fillColor: Color { Self.background(isSelected: isSelected) }

    var labelColor: Color { Self.foreground(isSelected: isSelected) }

    var edgeColor: Color? { Self.border(isSelected: isSelected) }

    public var body: some View {
        Button(action: action) {
            content
                .foregroundStyle(labelColor)
                .padding(.horizontal, OursSpacing.md)
                .frame(maxWidth: size.fillsWidth ? .infinity : nil, minHeight: size.height)
                .background(fillColor)
                .clipShape(shape)
                .overlay {
                    if let edgeColor {
                        shape.strokeBorder(edgeColor, lineWidth: OursStroke.hairline)
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
            if size.stacksSymbol {
                Image(systemName: systemImage)
                    .font(.system(size: size.symbolSize))
                    .accessibilityHidden(true)
            } else {
                Image(systemName: systemImage)
                    .imageScale(.small)
                    .accessibilityHidden(true)
            }
        }
    }

    private var label: some View {
        Text(title)
            .oursTextStyle(size.textStyle)
    }
}
