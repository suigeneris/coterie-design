import SwiftUI

public struct OursAvatarGroup: View {
    public struct Person: Identifiable, Sendable {
        public let id: UUID
        public let name: String
        public let imageURL: URL?
        public let isYou: Bool

        public init(id: UUID, name: String, imageURL: URL?, isYou: Bool = false) {
            self.id = id
            self.name = name
            self.imageURL = imageURL
            self.isYou = isYou
        }
    }

    /// `.standard`: 32pt circles, 8pt apart. `.compact`: 24pt circles overlapping by 6, each
    /// with a 2pt white edge so photos and initials read as one set, as on the ownership card.
    public enum Style: Sendable {
        case standard
        case compact

        var diameter: CGFloat { self == .compact ? OursSize.avatarCompact : OursSize.avatar }
        var spacing: CGFloat { self == .compact ? -Self.compactOverlap : OursSpacing.xs }
        static let compactOverlap: CGFloat = 6
    }

    private let people: [Person]
    private let showsOpenPlace: Bool
    private let style: Style

    public init(people: [Person], showsOpenPlace: Bool, style: Style = .standard) {
        self.people = people
        self.showsOpenPlace = showsOpenPlace
        self.style = style
    }

    public nonisolated static func initials(for name: String) -> String {
        name.split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .map { $0.prefix(1).uppercased() }
            .joined()
    }

    nonisolated static func spokenName(for name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Person" : trimmed
    }

    nonisolated static let youBackground = OursColor.forest

    nonisolated static let youForeground = Color.white

    nonisolated static let youLabel = "You"

    nonisolated static func spokenName(for person: Person) -> String {
        person.isYou ? youLabel : spokenName(for: person.name)
    }

    public var body: some View {
        HStack(spacing: style.spacing) {
            ForEach(people) { person in
                OursAvatar(person: person, diameter: style.diameter)
                    .background {
                        if style == .compact {
                            Circle().fill(OursColor.surfaceBase).padding(-OursStroke.strong)
                        }
                    }
            }
            if showsOpenPlace {
                Image(systemName: "plus")
                    .font(.system(size: OursIconSize.sm, weight: .semibold))
                    .foregroundStyle(OursColor.slate)
                    .frame(width: style.diameter, height: style.diameter)
                    .background(OursColor.mist, in: Circle())
                    .accessibilityLabel("Open place")
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct OursAvatar: View {
    let person: OursAvatarGroup.Person
    let diameter: CGFloat

    var body: some View {
        ZStack {
            Circle().fill(person.isYou ? OursAvatarGroup.youBackground : OursColor.mist)
            content
        }
        .frame(width: diameter, height: diameter)
        .clipShape(Circle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(OursAvatarGroup.spokenName(for: person))
    }

    @ViewBuilder
    private var content: some View {
        if person.isYou {
            Text(OursAvatarGroup.youLabel)
                .font(.oursCaptionSemibold)
                .foregroundStyle(OursAvatarGroup.youForeground)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        } else if let url = person.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    fallback
                default:
                    Color.clear
                }
            }
        } else {
            fallback
        }
    }

    @ViewBuilder
    private var fallback: some View {
        let initials = OursAvatarGroup.initials(for: person.name)
        if initials.isEmpty {
            Image(systemName: "person.fill")
                .font(.system(size: OursIconSize.sm))
                .foregroundStyle(OursColor.slate)
        } else {
            Text(initials)
                .oursTextStyle(.caption)
                .foregroundStyle(OursColor.slate)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
}
