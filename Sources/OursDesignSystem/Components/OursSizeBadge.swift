import SwiftUI

public struct OursSizeBadge: View {
    public enum Emphasis: Sendable {
        case strip
        case detail

        var fillsWidth: Bool { self == .strip }

        var cornerRadius: CGFloat { self == .strip ? 0 : OursRadius.xs }

        var verticalPadding: CGFloat { self == .strip ? OursSpacing.xxs : OursSpacing.xs }

        var horizontalPadding: CGFloat { self == .strip ? 0 : 14 }

        var valueLineHeight: CGFloat? {
            self == .strip ? OursTextStyle.bodyLargeStrong.lineHeight : OursTextStyle.h2.lineHeight
        }

        var valueFont: Font {
            switch self {
            case .strip:
                .ours(.bodyLargeStrong)
            case .detail:
                .ours(.interBold, size: OursTextStyle.h2.size, relativeTo: OursTextStyle.h2.relativeTo)
            }
        }
    }

    private static let labelTrackingEm: CGFloat = 0.06

    private let size: String
    private let emphasis: Emphasis

    public init(_ size: String, emphasis: Emphasis = .strip) {
        self.size = size
        self.emphasis = emphasis
    }

    nonisolated static let background = OursColor.yellow

    nonisolated static let foreground = OursColor.ink

    nonisolated static func spokenLabel(for size: String) -> String {
        "Size \(size.trimmingCharacters(in: .whitespacesAndNewlines))"
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: OursSpacing.xxs) {
            Text("Size")
                .textCase(.uppercase)
                .font(.oursCaptionSemibold)
                .tracking(OursTextStyle.caption.size * Self.labelTrackingEm)
            Text(size)
                .font(emphasis.valueFont)
                .frame(minHeight: emphasis.valueLineHeight)
        }
        .foregroundStyle(Self.foreground)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .padding(.horizontal, emphasis.horizontalPadding)
        .padding(.vertical, emphasis.verticalPadding)
        .frame(maxWidth: emphasis.fillsWidth ? .infinity : nil)
        .background(Self.background)
        .clipShape(RoundedRectangle(cornerRadius: emphasis.cornerRadius, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Self.spokenLabel(for: size))
    }
}
