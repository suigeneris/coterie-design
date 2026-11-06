import SwiftUI

public struct OursAvatarGroup: View {
    public struct Person: Identifiable, Sendable {
        public let id: UUID
        public let name: String
        public let imageURL: URL?

        public init(id: UUID, name: String, imageURL: URL?) {
            self.id = id
            self.name = name
            self.imageURL = imageURL
        }
    }

    private let people: [Person]
    private let showsOpenPlace: Bool

    public init(people: [Person], showsOpenPlace: Bool) {
        self.people = people
        self.showsOpenPlace = showsOpenPlace
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

    public var body: some View {
        HStack(spacing: OursSpacing.xs) {
            ForEach(people) { person in
                OursAvatar(person: person)
            }
            if showsOpenPlace {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OursColor.slate)
                    .frame(width: OursAvatar.diameter, height: OursAvatar.diameter)
                    .background(OursColor.mist, in: Circle())
                    .accessibilityLabel("Open place")
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct OursAvatar: View {
    static let diameter: CGFloat = 32

    let person: OursAvatarGroup.Person

    var body: some View {
        ZStack {
            Circle().fill(OursColor.mist)
            content
        }
        .frame(width: Self.diameter, height: Self.diameter)
        .clipShape(Circle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(OursAvatarGroup.spokenName(for: person.name))
    }

    @ViewBuilder
    private var content: some View {
        if let url = person.imageURL {
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
                .font(.system(size: 14))
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
