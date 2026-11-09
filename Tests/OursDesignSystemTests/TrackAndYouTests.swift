import Testing
import SwiftUI
@testable import OursDesignSystem

@MainActor
func accessibilityLabels<V: View>(of view: V) -> [String] {
    let host = UIHostingController(rootView: view.frame(width: 300, height: 100))
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
    window.rootViewController = host
    window.makeKeyAndVisible()
    host.view.layoutIfNeeded()
    var labels: [String] = []
    func walk(_ node: NSObject) {
        if node.isAccessibilityElement { labels.append(node.accessibilityLabel ?? "") }
        let count = node.accessibilityElementCount()
        if count != NSNotFound {
            for index in 0..<count {
                if let child = node.accessibilityElement(at: index) as? NSObject { walk(child) }
            }
        }
        for child in (node.accessibilityElements ?? []).compactMap({ $0 as? NSObject }) { walk(child) }
        for child in (node as? UIView)?.subviews ?? [] { walk(child) }
    }
    walk(host.view)
    return labels
}

@MainActor
func renderedHeight<V: View>(of view: V) -> CGFloat {
    ImageRenderer(content: view.frame(width: 200)).uiImage?.size.height ?? 0
}

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

    @Test func youIsSpokenAsYouWhateverTheName() {
        let you = OursAvatarGroup.Person(id: UUID(), name: "Jonathan Aguele", imageURL: nil, isYou: true)
        #expect(OursAvatarGroup.spokenName(for: you) == "You")
        let blank = OursAvatarGroup.Person(id: UUID(), name: "", imageURL: nil, isYou: true)
        #expect(OursAvatarGroup.spokenName(for: blank) == "You")
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

    @Test func youIgnoresThePhoto() {
        let url = URL(string: "https://example.com/me.jpg")
        #expect(OursAvatarGroup.Person(id: UUID(), name: "Ann", imageURL: url).showsPhoto)
        #expect(!OursAvatarGroup.Person(id: UUID(), name: "Ann", imageURL: nil).showsPhoto)
        #expect(!OursAvatarGroup.Person(id: UUID(), name: "Ann", imageURL: url, isYou: true).showsPhoto)
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
