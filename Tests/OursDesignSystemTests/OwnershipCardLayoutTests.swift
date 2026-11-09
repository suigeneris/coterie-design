import Testing
import SwiftUI
@testable import OursDesignSystem

@MainActor
struct OwnershipCardLayoutTests {
    private static let amara = OursAvatarGroup.Person(id: UUID(), name: "Amara O.", imageURL: nil)

    @ViewBuilder
    private func card(status: String = "Ready to book", withAction: Bool, size: DynamicTypeSize) -> some View {
        Group {
            if withAction {
                OursOwnershipCard(
                    title: "Puzzle Bag", status: status, places: 3, filled: 3, coOwners: [Self.amara], onOpen: {},
                    media: { OursColor.peach },
                    action: { OursButton("Book", kind: .secondary, size: .compact) {} }
                )
            } else {
                OursOwnershipCard(
                    title: "Puzzle Bag", status: status, places: 3, filled: 3, coOwners: [Self.amara], onOpen: {},
                    media: { OursColor.peach }
                )
            }
        }
        .environment(\.dynamicTypeSize, size)
        .frame(width: 354)
    }

    @Test func theActionStaysBesideTheTextAtDefaultSizes() {
        let with = renderedHeight(of: card(withAction: true, size: .large), width: 354)
        let without = renderedHeight(of: card(withAction: false, size: .large), width: 354)
        #expect(abs(with - without) <= 0.5, "with an action \(with)pt, without \(without)pt")
    }

    @Test func theActionSitsUnderTheTextAtAccessibilitySizes() {
        let with = renderedHeight(of: card(withAction: true, size: .accessibility3), width: 354)
        let without = renderedHeight(of: card(withAction: false, size: .accessibility3), width: 354)
        let stacked = OursSize.minimumTouchTarget + OursSpacing.md
        #expect(with >= without + OursSize.minimumTouchTarget, "with an action \(with)pt, without \(without)pt")
        #expect(with <= without + stacked + 1, "with an action \(with)pt, without \(without)pt")
    }

    @Test func theActionDoesNotSqueezeTheTitleAtAccessibilitySizes() throws {
        let with = try #require(RenderedPixels(card(withAction: true, size: .accessibility3)))
        let without = try #require(RenderedPixels(card(withAction: false, size: .accessibility3)))
        let titleWith = with.horizontalExtent(of: OursColor.ink)
        let titleWithout = without.horizontalExtent(of: OursColor.ink)
        #expect(titleWithout > 0)
        #expect(titleWith >= titleWithout, "title is \(titleWith)pt wide with an action, \(titleWithout)pt without")
    }

    @Test func anEmptyStatusTakesNoSpace() {
        let size = DynamicTypeSize.accessibility5
        let line = renderedHeight(
            of: Text(verbatim: "OK").oursTextStyle(.bodySmall).environment(\.dynamicTypeSize, size),
            width: 354,
            scale: 3
        )
        let with = renderedHeight(of: card(status: "OK", withAction: false, size: size), width: 354, scale: 3)
        let without = renderedHeight(of: card(status: "", withAction: false, size: size), width: 354, scale: 3)
        let gap = with - without - line
        #expect(gap >= 1, "status line \(line)pt, card \(with)pt with it and \(without)pt without: the gap is \(gap)pt")
    }

    @Test func anEmptyStatusIsNotSpokenByTheCard() {
        let spoken = accessibilityLabels(of: card(status: "", withAction: false, size: .large))
        #expect(spoken.contains("Puzzle Bag. With Amara O."), "\(spoken)")
    }
}
