import SwiftUI

public struct OursStepProgress: View {
    private let current: Int
    private let total: Int

    public init(current: Int, total: Int) {
        self.current = current
        self.total = total
    }

    public var body: some View {
        let steps = max(total, 0)
        let reached = min(max(current, 0), steps)

        VStack(spacing: OursSpacing.xs) {
            Text("\(reached) of \(steps)")
                .oursTextStyle(.bodySmall)
                .foregroundStyle(OursColor.slate)

            HStack(spacing: OursSpacing.xxs) {
                ForEach(0..<steps, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(index < reached ? OursColor.forest : OursColor.mist)
                        .frame(height: 8)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(reached) of \(steps)")
    }
}
