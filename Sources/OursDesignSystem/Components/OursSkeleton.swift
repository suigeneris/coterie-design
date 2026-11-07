import SwiftUI

public struct OursSkeleton: View {
    private let cornerRadius: CGFloat

    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(cornerRadius: CGFloat = OursRadius.xs) {
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(OursColor.mist)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(
                    OursMotion.respectingReduceMotion(
                        .easeIn(duration: OursMotion.standard),
                        reduceMotion: reduceMotion
                    )
                ) {
                    isVisible = true
                }
            }
            .accessibilityHidden(true)
    }
}
