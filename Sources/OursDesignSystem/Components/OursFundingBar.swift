import SwiftUI

public struct OursFundingBar: View {
    private let filled: Int
    private let total: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(filled: Int, total: Int) {
        self.filled = filled
        self.total = total
    }

    public nonisolated static func label(filled: Int, total: Int) -> String {
        "\(filled) of \(total) filled"
    }

    public nonisolated static func fraction(filled: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return min(max(Double(filled) / Double(total), 0), 1)
    }

    public var body: some View {
        let label = Self.label(filled: filled, total: total)
        let fraction = Self.fraction(filled: filled, total: total)

        VStack(alignment: .leading, spacing: OursSpacing.xs) {
            Text(label)
                .oursTextStyle(.bodySmall)
                .foregroundStyle(OursColor.slate)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: OursRadius.xxs, style: .continuous)
                        .fill(OursColor.mist)
                    RoundedRectangle(cornerRadius: OursRadius.xxs, style: .continuous)
                        .fill(OursColor.forest)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .frame(height: OursSize.progressTrack)
            .animation(
                OursMotion.respectingReduceMotion(
                    .linear(duration: OursMotion.standard),
                    reduceMotion: reduceMotion
                ),
                value: fraction
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
    }
}
