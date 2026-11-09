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

    @Test func aStepTrackIsSpokenAsOneStepOfTheTotal() {
        #expect(OursStepProgress.label(current: 2, total: 4) == "Step 2 of 4")
    }

    @Test func aStepTrackIsSpokenWithinItsBounds() {
        #expect(OursStepProgress.label(current: 9, total: 4) == "Step 4 of 4")
        #expect(OursStepProgress.label(current: -1, total: 4) == "Step 0 of 4")
        #expect(OursStepProgress.label(current: 2, total: -3) == "Step 0 of 0")
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
}
