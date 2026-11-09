import Testing
import SwiftUI
@testable import OursDesignSystem

@MainActor
struct LabellessTrackTests {
    @Test func aStepTrackWithoutItsLabelIsJustTheTrack() {
        #expect(renderedHeight(of: OursStepProgress(current: 1, total: 3, showsLabel: false)) == OursSize.progressTrack)
    }

    @Test func aFundingBarWithoutItsLabelIsJustTheTrack() {
        #expect(renderedHeight(of: OursFundingBar(filled: 1, total: 3, showsLabel: false)) == OursSize.progressTrack)
    }

    @Test func theLabelIsShownByDefault() {
        #expect(renderedHeight(of: OursStepProgress(current: 1, total: 3)) > OursSize.progressTrack)
        #expect(renderedHeight(of: OursFundingBar(filled: 1, total: 3)) > OursSize.progressTrack)
        #expect(renderedHeight(of: OursStepProgress(current: 1, total: 3, showsLabel: true))
                == renderedHeight(of: OursStepProgress(current: 1, total: 3)))
        #expect(renderedHeight(of: OursFundingBar(filled: 1, total: 3, showsLabel: true))
                == renderedHeight(of: OursFundingBar(filled: 1, total: 3)))
    }

    @Test func aLabelledStepTrackIsSpokenAsOneStepOfTheTotal() {
        #expect(accessibilityLabels(of: OursStepProgress(current: 2, total: 4)) == ["Step 2 of 4"])
    }

    @Test func aLabelledFundingBarIsSpokenAsOneFilledOfTheTotal() {
        #expect(accessibilityLabels(of: OursFundingBar(filled: 2, total: 3)) == ["2 of 3 filled"])
    }

    @Test func aStepTrackWithoutItsLabelIsHiddenFromVoiceOver() {
        #expect(accessibilityLabels(of: OursStepProgress(current: 2, total: 4, showsLabel: false)).isEmpty)
    }

    @Test func aFundingBarWithoutItsLabelIsHiddenFromVoiceOver() {
        #expect(accessibilityLabels(of: OursFundingBar(filled: 2, total: 3, showsLabel: false)).isEmpty)
    }
}

struct YouAvatarTests {
    @Test func aPersonIsNotYouByDefault() {
        #expect(!OursAvatarGroup.Person(id: UUID(), name: "Seed A", imageURL: nil).isYou)
        #expect(OursAvatarGroup.Person(id: UUID(), name: "Seed A", imageURL: nil, isYou: true).isYou)
    }

    @Test func youIsSpokenAsYouWhateverTheNameOrPhoto() {
        let url = URL(string: "https://example.com/me.jpg")
        for (name, imageURL) in [("Jonathan Aguele", nil), ("", nil), ("Jonathan Aguele", url)] {
            let you = OursAvatarGroup.Person(id: UUID(), name: name, imageURL: imageURL, isYou: true)
            #expect(OursAvatarGroup.spokenName(for: you) == OursAvatarGroup.youLabel)
        }
        #expect(OursAvatarGroup.youLabel == "You")
    }

    @Test func everyoneElseIsSpokenByName() {
        let other = OursAvatarGroup.Person(id: UUID(), name: " Ann Lee ", imageURL: nil)
        #expect(OursAvatarGroup.spokenName(for: other) == "Ann Lee")
        let blank = OursAvatarGroup.Person(id: UUID(), name: "", imageURL: nil)
        #expect(OursAvatarGroup.spokenName(for: blank) == "Person")
    }

    @Test func youIsWhiteOnForestAndMeetsAA() {
        #expect(OursAvatarGroup.youBackground == OursColor.forest)
        #expect(OursAvatarGroup.youForeground == .white)
        let ratio = contrast(OursAvatarGroup.youForeground, OursAvatarGroup.youBackground)
        #expect(ratio >= 4.5, "white on forest is \(String(format: "%.2f", ratio)):1")
    }

    @MainActor @Test func youIgnoresThePhoto() throws {
        let url = URL(string: "https://example.com/me.jpg")
        let you = OursAvatarGroup.Person(id: UUID(), name: "Ann", imageURL: url, isYou: true)
        let pixels = try #require(RenderedPixels(OursAvatarGroup(people: [you], showsOpenPlace: false)))
        #expect(pixels.isColor(OursAvatarGroup.youBackground, x: 4, y: pixels.pointHeight / 2))
        #expect(pixels.contains(OursAvatarGroup.youForeground))
    }

    @MainActor @Test(arguments: [OursAvatarGroup.Style.standard, .compact])
    func theGroupSpeaksYouForYourPlace(_ style: OursAvatarGroup.Style) {
        let people = [
            OursAvatarGroup.Person(id: UUID(), name: "Ann Lee", imageURL: nil),
            OursAvatarGroup.Person(id: UUID(), name: "Jonathan Aguele", imageURL: nil, isYou: true)
        ]
        let spoken = accessibilityLabels(of: OursAvatarGroup(people: people, showsOpenPlace: false, style: style))
        #expect(spoken.joined(separator: ", ").contains("You"))
        #expect(!spoken.joined(separator: ", ").contains("Jonathan"))
    }
}
