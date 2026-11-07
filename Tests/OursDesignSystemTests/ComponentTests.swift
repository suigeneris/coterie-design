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

struct ComponentContrastTests {
    @Test func ownershipCardTextMeetsAA() {
        #expect(contrast(OursColor.ink, OursColor.lavender) >= 4.5, "title on lavender")
        #expect(contrast(OursOwnershipDisc.label, OursOwnershipDisc.fill) >= 4.5, "fraction on its disc")
        #expect(contrast(OursColor.slate, OursColor.lavender) >= 4.5, "detail on lavender")
    }

    /// The disc has to stand out from the card it sits on, not just carry legible text.
    /// `lavenderDeep` on `lavender` was 1.13:1.
    @Test func ownershipDiscStandsOutFromItsCard() {
        #expect(contrast(OursOwnershipDisc.fill, OursColor.lavender) >= 3.0)
    }

    @Test func avatarInitialsMeetAAOnMist() {
        #expect(contrast(OursColor.slate, OursColor.mist) >= 4.5)
    }

    @Test func informationCardIconMeetsAAOnSage() {
        #expect(contrast(OursColor.slate, OursColor.sage) >= 4.5)
    }
}
