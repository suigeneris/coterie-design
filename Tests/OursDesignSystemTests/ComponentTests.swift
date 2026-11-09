import Testing
import SwiftUI
@testable import OursDesignSystem

struct FundingBarTests {
    @Test func labelReadsFilledOfTotal() {
        #expect(OursFundingBar.label(filled: 3, total: 4) == "3 of 4 filled")
        #expect(OursFundingBar.label(filled: 1, total: 3) == "1 of 3 filled")
    }

    @Test func fractionIsFilledOverTotal() {
        #expect(OursFundingBar.fraction(filled: 1, total: 3) == 1.0 / 3.0)
        #expect(OursFundingBar.fraction(filled: 0, total: 3) == 0)
        #expect(OursFundingBar.fraction(filled: 3, total: 3) == 1)
    }

    @Test func fractionIsClampedToTheUnitInterval() {
        #expect(OursFundingBar.fraction(filled: 5, total: 3) == 1)
        #expect(OursFundingBar.fraction(filled: -1, total: 3) == 0)
    }

    @Test func fractionIsZeroWithoutATotal() {
        #expect(OursFundingBar.fraction(filled: 1, total: 0) == 0)
        #expect(OursFundingBar.fraction(filled: 1, total: -2) == 0)
    }
}

struct AvatarGroupTests {
    @Test func initialsTakeTheFirstLetterOfTheFirstTwoWords() {
        #expect(OursAvatarGroup.initials(for: "Seed A") == "SA")
        #expect(OursAvatarGroup.initials(for: "  Ann  Lee  Smith ") == "AL")
    }

    @Test func initialsAreUppercased() {
        #expect(OursAvatarGroup.initials(for: "madonna") == "M")
        #expect(OursAvatarGroup.initials(for: "ann lee") == "AL")
    }

    @Test func initialsSplitOnAnyWhitespace() {
        #expect(OursAvatarGroup.initials(for: "Ann\tLee") == "AL")
        #expect(OursAvatarGroup.initials(for: "Ann\nLee") == "AL")
    }

    @Test func blankNamesHaveNoInitials() {
        #expect(OursAvatarGroup.initials(for: "") == "")
        #expect(OursAvatarGroup.initials(for: "   ") == "")
    }

    @Test func spokenNameIsTheTrimmedName() {
        #expect(OursAvatarGroup.spokenName(for: "Seed A") == "Seed A")
        #expect(OursAvatarGroup.spokenName(for: "  Ann Lee ") == "Ann Lee")
    }

    @Test func blankNamesAreSpokenAsPerson() {
        #expect(OursAvatarGroup.spokenName(for: "") == "Person")
        #expect(OursAvatarGroup.spokenName(for: "   ") == "Person")
    }

    @Test func aPersonCanCrossAConcurrencyBoundary() {
        func requireSendable<T: Sendable>(_: T.Type) {}
        requireSendable(OursAvatarGroup.Person.self)
    }
}

struct TextAreaTests {
    @Test func countLabelShowsCountOverLimit() {
        #expect(OursTextArea.countLabel(text: "abc", limit: 10) == "3/10")
        #expect(OursTextArea.countLabel(text: "", limit: 2000) == "0/2000")
    }

    @Test func countLabelCountsCodePointsNotCharacters() {
        #expect(OursTextArea.countLabel(text: "👍🏽", limit: 10) == "2/10")
        #expect(OursTextArea.countLabel(text: "e\u{0301}", limit: 10) == "2/10")
    }
}

struct FieldStateMessageTests {
    @Test func messageColourFollowsTheState() {
        #expect(OursFieldState.neutral.messageColor == OursColor.stone)
        #expect(OursFieldState.error("bad").messageColor == OursColor.error)
        #expect(OursFieldState.success().messageColor == OursColor.success)
    }
}

struct ChipTests {
    @Test func selectedIsForestWithAWhiteLabel() {
        #expect(OursChip.background(isSelected: true) == OursColor.forest)
        #expect(OursChip.foreground(isSelected: true) == .white)
    }

    @Test func unselectedIsSurfaceBaseWithAnInkLabel() {
        #expect(OursChip.background(isSelected: false) == OursColor.surfaceBase)
        #expect(OursChip.foreground(isSelected: false) == OursColor.ink)
    }

    @Test func unselectedIsOutlinedSoItReadsOnCream() {
        #expect(OursChip.border(isSelected: false) == OursColor.outline)
        #expect(OursChip.border(isSelected: true) == nil)
    }

    @Test(arguments: [true, false])
    func labelMeetsAAOnItsFill(_ isSelected: Bool) {
        let ratio = contrast(
            OursChip.foreground(isSelected: isSelected),
            OursChip.background(isSelected: isSelected)
        )
        #expect(ratio >= 4.5, "isSelected \(isSelected) is \(String(format: "%.2f", ratio)):1")
    }
}

struct SizeBadgeTests {
    @Test func isInkOnYellow() {
        #expect(OursSizeBadge.background == OursColor.yellow)
        #expect(OursSizeBadge.foreground == OursColor.ink)
    }

    @Test func textPairMeetsAA() {
        let ratio = contrast(OursSizeBadge.foreground, OursSizeBadge.background)
        #expect(ratio >= 4.5, "ink on yellow is \(String(format: "%.2f", ratio)):1")
    }

    @Test func isSpokenAsSizeThenTheValue() {
        #expect(OursSizeBadge.spokenLabel(for: "UK 5") == "Size UK 5")
        #expect(OursSizeBadge.spokenLabel(for: "  EU 38 ") == "Size EU 38")
    }

    @Test func detailPaddingIsEightByTwelve() {
        #expect(OursSizeBadge.Emphasis.detail.verticalPadding == OursSpacing.xs)
        #expect(OursSizeBadge.Emphasis.detail.horizontalPadding == OursSpacing.sm)
    }

    @MainActor @Test func stripRendersAboutThirtyOnePointsTall() {
        let height = renderedHeight(of: OursSizeBadge("UK 5", emphasis: .strip), width: 112)
        #expect(abs(height - 31) <= 1.5, "strip is \(height)pt")
    }

    @MainActor @Test func detailRendersAboutFortyEightPointsTall() {
        let height = renderedHeight(of: OursSizeBadge("UK 5", emphasis: .detail))
        #expect(abs(height - 48) <= 1.5, "detail is \(height)pt")
    }

    @MainActor @Test func stripFillsItsContainerWithSquareCorners() throws {
        let pixels = try #require(RenderedPixels(OursSizeBadge("UK 5", emphasis: .strip).frame(width: 112)))
        let (right, bottom) = (pixels.pointWidth - 0.5, pixels.pointHeight - 0.5)
        #expect(pixels.pointWidth == 112)
        for (pointX, pointY) in [(0.5, 0.5), (right, 0.5), (0.5, bottom), (right, bottom)] {
            #expect(pixels.isColor(OursSizeBadge.background, x: pointX, y: pointY), "corner at \(pointX), \(pointY)")
        }
    }

    @MainActor @Test func detailHugsItsContentAndRoundsItsCorners() throws {
        let pixels = try #require(RenderedPixels(OursSizeBadge("UK 5", emphasis: .detail)))
        #expect(pixels.pointWidth < 200)
        #expect(pixels.isColor(OursSizeBadge.background, x: OursSpacing.xs, y: pixels.pointHeight / 2))
        #expect(!pixels.isOpaque(x: 0.5, y: 0.5))
    }

    @Test func aBadgeCanCrossAConcurrencyBoundary() {
        func requireSendable<T: Sendable>(_: T.Type) {}
        requireSendable(OursSizeBadge.Emphasis.self)
    }
}

@MainActor
struct ChipSizeTests {
    private nonisolated static let sizes: [OursChipSize] = [.regular, .large, .tile]

    private func chip(_ size: OursChipSize, isSelected: Bool) -> some View {
        OursChip("2", isSelected: isSelected, size: size) {}
            .frame(width: 160, alignment: .leading)
    }

    @Test(arguments: sizes)
    func everySizeRendersAtLeastTheTouchTarget(_ size: OursChipSize) {
        #expect(renderedHeight(of: chip(size, isSelected: false)) >= OursSize.minimumTouchTarget)
    }

    @Test func largeRendersFiftySixTallAndTileOneTwentyEight() {
        #expect(abs(renderedHeight(of: chip(.large, isSelected: false)) - 56) <= 0.5)
        #expect(abs(renderedHeight(of: chip(.tile, isSelected: false)) - 128) <= 0.5)
    }

    @Test func largeSetsItsValueInH3AndTileSetsItsLabelAsAButton() {
        #expect(OursChipSize.regular.textStyle == .body)
        #expect(OursChipSize.large.textStyle == .h3)
        #expect(OursChipSize.tile.textStyle == .button)
    }

    @Test func tileIsRoundedAtMediumAndTheOthersAtExtraSmall() {
        #expect(OursChipSize.regular.cornerRadius == OursRadius.xs)
        #expect(OursChipSize.large.cornerRadius == OursRadius.xs)
        #expect(OursChipSize.tile.cornerRadius == OursRadius.md)
    }

    @Test func largeAndTileShareTheWidthOfAGridAndRegularHugsItsLabel() {
        #expect(!OursChipSize.regular.fillsWidth)
        #expect(OursChipSize.large.fillsWidth)
        #expect(OursChipSize.tile.fillsWidth)
    }

    @Test func onlyTheTileStacksItsSymbolAboveItsLabel() {
        #expect(!OursChipSize.regular.stacksSymbol)
        #expect(!OursChipSize.large.stacksSymbol)
        #expect(OursChipSize.tile.stacksSymbol)
    }

    @Test(arguments: sizes, [true, false])
    func fillEdgeAndLabelAreTheChipColoursAtEverySize(_ size: OursChipSize, _ isSelected: Bool) throws {
        let pixels = try #require(RenderedPixels(chip(size, isSelected: isSelected)))
        let middle = pixels.pointHeight / 2
        let fill = OursChip.background(isSelected: isSelected)
        #expect(pixels.isColor(fill, x: 6, y: middle), "\(size) fill")
        #expect(pixels.isColor(OursChip.border(isSelected: isSelected) ?? fill, x: 0.5, y: middle), "\(size) edge")
        #expect(pixels.contains(OursChip.foreground(isSelected: isSelected)), "\(size) label")
    }

    @Test func aSizeCanCrossAConcurrencyBoundary() {
        func requireSendable<T: Sendable>(_: T.Type) {}
        requireSendable(OursChipSize.self)
    }
}

struct ComponentContrastTests {
    /// The ownership card is white now: title ink, status slate, "Just you so far" stone.
    @Test func ownershipCardTextMeetsAAOnWhite() {
        for (name, color) in [("ink", OursColor.ink), ("slate", OursColor.slate), ("stone", OursColor.stone)] {
            #expect(contrast(color, OursColor.surfaceBase) >= 4.5, "\(name) on the card")
        }
    }

    /// A taken arc of the share ring must stand out from the white card it sits on.
    @Test func shareRingFillMeetsUIContrast() {
        #expect(contrast(OursColor.forest, OursColor.surfaceBase) >= 3.0)
    }

    @Test func avatarInitialsMeetAAOnMist() {
        #expect(contrast(OursColor.slate, OursColor.mist) >= 4.5)
    }

    @Test func informationCardIconMeetsAAOnSage() {
        #expect(contrast(OursColor.slate, OursColor.sage) >= 4.5)
    }
}

struct ShareRingTests {
    @Test func oneArcPerPlace() {
        for places in 2...4 {
            #expect(OursShares.segments(places: places, filled: 1).count == places)
        }
        #expect(OursShares.segments(places: 0, filled: 0).isEmpty)
    }

    @Test func takenPlacesFillFromTwelveOClock() {
        let filled = OursShares.segments(places: 3, filled: 2).map(\.isFilled)
        #expect(filled == [true, true, false])
    }

    @Test func filledIsClampedToThePlaces() {
        // Computed outside #expect: `allSatisfy` rethrows, and the macro expansion would
        // otherwise demand `try` on a call that can't throw.
        let overfilled = OursShares.segments(places: 3, filled: 7).map(\.isFilled)
        let underfilled = OursShares.segments(places: 3, filled: -1).map(\.isFilled)
        #expect(overfilled == [true, true, true])
        #expect(underfilled == [false, false, false])
    }

    /// Arcs stay inside the circle, in order, with a gap between each pair.
    @Test(arguments: [2, 3, 4])
    func arcsAreOrderedAndSeparated(_ places: Int) {
        let segments = OursShares.segments(places: places, filled: 0)
        for (index, segment) in segments.enumerated() {
            #expect(segment.from > 0 && segment.to < 1)
            #expect(segment.from < segment.to)
            if index > 0 { #expect(segments[index - 1].to < segment.from) }
        }
    }

    @Test func ringClosesOnlyWhenEveryPlaceIsTaken() {
        #expect(!OursShares.isComplete(places: 3, filled: 2))
        #expect(OursShares.isComplete(places: 3, filled: 3))
        #expect(!OursShares.isComplete(places: 0, filled: 0))
    }
}

struct OwnershipCardWordingTests {
    @Test func coOwnersAreNamedNotCounted() {
        #expect(OursShares.coOwnersPhrase([]) == "Just you so far")
        #expect(OursShares.coOwnersPhrase(["Amara O."]) == "With Amara O.")
        #expect(OursShares.coOwnersPhrase(["Amara O.", "Jo T."]) == "With Amara O. and Jo T.")
        #expect(OursShares.coOwnersPhrase(["Amara O.", "Jo T.", "Sam M."]) == "With Amara O., Jo T. and Sam M.")
    }

    @Test func aBlankNameIsSpokenAsPerson() {
        #expect(OursShares.coOwnersPhrase(["  "]) == "With Person")
    }

    @Test func theCardReadsAsOneSentence() {
        #expect(OursShares.cardLabel(title: "Puzzle Bag", status: "1 place left", coOwners: ["Amara O."])
                == "Puzzle Bag. 1 place left. With Amara O.")
    }

    /// The full stop is added only when the last name doesn't already end with one.
    @Test func theCardEndsWithExactlyOneFullStop() {
        #expect(OursShares.cardLabel(title: "Puzzle Bag", status: "1 place left", coOwners: ["Amara"])
                == "Puzzle Bag. 1 place left. With Amara.")
        #expect(OursShares.cardLabel(title: "New item", status: "2 places left", coOwners: [])
                == "New item. 2 places left. Just you so far.")
    }

    @Test func anEmptyStatusIsLeftOutOfTheSentence() {
        #expect(OursShares.cardLabel(title: "Puzzle Bag", status: "", coOwners: ["Amara O."])
                == "Puzzle Bag. With Amara O.")
        #expect(OursShares.cardLabel(title: "Puzzle Bag", status: "  \n ", coOwners: ["Amara O."])
                == "Puzzle Bag. With Amara O.")
        #expect(OursShares.cardLabel(title: "New item", status: "", coOwners: [])
                == "New item. Just you so far.")
    }
}

struct CompactSizeTests {
    /// The compact button sits inside a card, so it hugs its label but still meets 44pt.
    @Test(arguments: [OursButtonKind.primary, .secondary, .tertiary, .destructive])
    func compactButtonsHugTheirLabelAndMeetTheTarget(_ kind: OursButtonKind) {
        let metrics = OursButtonMetrics(kind: kind, size: .compact)
        #expect(!metrics.isFullWidth)
        #expect(metrics.height >= OursSize.minimumTouchTarget)
        #expect(metrics.cornerRadius == OursRadius.xs)
    }

    @Test func regularButtonsAreUnchanged() {
        let primary = OursButtonMetrics(kind: .primary, size: .regular)
        #expect(primary.isFullWidth && primary.height == OursSize.buttonHeight && primary.cornerRadius == OursRadius.md)
        #expect(!OursButtonMetrics(kind: .tertiary, size: .regular).isFullWidth)
    }

    @Test func compactAvatarsOverlap() {
        #expect(OursAvatarGroup.Style.compact.diameter == OursSize.avatarCompact)
        #expect(OursAvatarGroup.Style.compact.spacing < 0)
        #expect(OursAvatarGroup.Style.standard.diameter == OursSize.avatar)
    }
}
