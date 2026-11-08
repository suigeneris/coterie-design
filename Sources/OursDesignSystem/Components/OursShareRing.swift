import SwiftUI

/// The geometry and wording behind the share ring and the ownership card. Pure, so it can be
/// tested without rendering.
public enum OursShares {
    /// One arc of the ring, as fractions of the full circle starting at 12 o'clock.
    public struct Segment: Equatable, Sendable {
        public let from: Double
        public let to: Double
        public let isFilled: Bool
    }

    /// Stroke width of the ring.
    static let lineWidth: CGFloat = 4
    /// Distance from the ring's frame to the centre of its stroke.
    static let inset: CGFloat = 3
    /// Gap between neighbouring arcs, measured along the ring.
    static let gap: CGFloat = 6
    /// The circular photo inside the ring: 62 in an 80 ring.
    static var photoDiameter: CGFloat { OursSize.shareRing - 18 }

    /// A ring closes into one circle once every place is taken, and stays closed after that.
    public static func isComplete(places: Int, filled: Int) -> Bool {
        places > 0 && filled >= places
    }

    /// One arc per place, `gap` apart, filled for the places taken. Empty for no places.
    public static func segments(places: Int, filled: Int) -> [Segment] {
        guard places > 0 else { return [] }
        let taken = min(max(filled, 0), places)
        let radius = Double(OursSize.shareRing / 2 - inset)
        let halfGap = Double(gap) / (2 * Double.pi * radius) / 2
        let share = 1 / Double(places)
        return (0..<places).map { index in
            Segment(
                from: Double(index) * share + halfGap,
                to: Double(index + 1) * share - halfGap,
                isFilled: index < taken
            )
        }
    }

    /// Who you share with, in words: "With Amara O.", "With Amara O. and Jo T.",
    /// "With Amara O., Jo T. and Sam M.", or "Just you so far". At most three names: a
    /// coterie has four owners at most, and you are never listed.
    public static func coOwnersPhrase(_ names: [String]) -> String {
        let shown = names.prefix(3).map { OursAvatarGroup.spokenName(for: $0) }
        switch shown.count {
        case 0: return "Just you so far"
        case 1: return "With \(shown[0])"
        default: return "With \(shown.dropLast().joined(separator: ", ")) and \(shown[shown.count - 1])"
        }
    }

    /// What VoiceOver reads for an ownership card: title, status, then who it's with.
    /// A name shown as an initial ("Amara O.") already ends the sentence, so no second full stop
    /// is added: VoiceOver would read "Amara O.." as a pause, and a braille display shows both.
    public static func cardLabel(title: String, status: String, coOwners: [String]) -> String {
        let who = coOwnersPhrase(coOwners)
        return "\(title). \(status). \(who)" + (who.hasSuffix(".") ? "" : ".")
    }
}

/// A ring of one arc per place around circular content, usually the item's photo.
///
/// While a coterie fills, each arc is `forest` once its place is taken and `mist` while it is
/// open. When the last place is taken the arcs close into one continuous `forest` circle,
/// which stays closed from then on. The ring is decorative: whatever shows it must say the
/// same in words, as the ownership card's label does.
public struct OursShareRing<Content: View>: View {
    private let places: Int
    private let filled: Int
    private let content: Content

    public init(places: Int, filled: Int, @ViewBuilder content: () -> Content) {
        self.places = places
        self.filled = filled
        self.content = content()
    }

    public var body: some View {
        ZStack {
            if OursShares.isComplete(places: places, filled: filled) {
                Circle()
                    .inset(by: OursShares.inset)
                    .stroke(OursColor.forest, lineWidth: OursShares.lineWidth)
            } else {
                ForEach(Array(OursShares.segments(places: places, filled: filled).enumerated()), id: \.offset) { _, segment in
                    Circle()
                        .inset(by: OursShares.inset)
                        .trim(from: segment.from, to: segment.to)
                        .stroke(
                            segment.isFilled ? OursColor.forest : OursColor.mist,
                            style: StrokeStyle(lineWidth: OursShares.lineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
            }

            content
                .frame(width: OursShares.photoDiameter, height: OursShares.photoDiameter)
                .clipShape(Circle())
        }
        .frame(width: OursSize.shareRing, height: OursSize.shareRing)
        .accessibilityHidden(true)
    }
}
