import SwiftUI

public struct OursStepProgress: View {
    private let current: Int
    private let total: Int
    private let showsLabel: Bool

    public init(current: Int, total: Int, showsLabel: Bool = true) {
        self.current = current
        self.total = total
        self.showsLabel = showsLabel
    }

    public var body: some View {
        let steps = max(total, 0)
        let reached = min(max(current, 0), steps)

        VStack(spacing: OursSpacing.xs) {
            if showsLabel {
                Text("\(reached) of \(steps)")
                    .oursTextStyle(.bodySmall)
                    .foregroundStyle(OursColor.slate)
            }

            HStack(spacing: OursSpacing.xxs) {
                ForEach(0..<steps, id: \.self) { index in
                    RoundedRectangle(cornerRadius: OursRadius.xxs, style: .continuous)
                        .fill(index < reached ? OursColor.forest : OursColor.mist)
                        .frame(height: OursSize.progressTrack)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(reached) of \(steps)")
        .accessibilityHidden(!showsLabel)
    }
}
