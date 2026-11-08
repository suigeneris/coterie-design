import SwiftUI

public struct OursProductCard<Media: View, Footer: View>: View {
    private let title: String
    private let subtitle: String
    private let price: String
    private let media: Media
    private let footer: Footer

    public init(
        title: String,
        subtitle: String,
        price: String,
        @ViewBuilder media: () -> Media,
        @ViewBuilder footer: () -> Footer
    ) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.media = media()
        self.footer = footer()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: OursSpacing.md) {
            media
                .frame(width: OursSize.thumbnail, height: OursSize.thumbnail)
                .clipShape(RoundedRectangle(cornerRadius: OursRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: OursSpacing.xs) {
                VStack(alignment: .leading, spacing: OursSpacing.xxs) {
                    Text(title)
                        .oursTextStyle(.h2)
                        .foregroundStyle(OursColor.ink)
                        .lineLimit(2)
                    Text(subtitle)
                        .oursTextStyle(.bodySmall)
                        .foregroundStyle(OursColor.stone)
                }
                Text(price)
                    .oursTextStyle(.bodyLargeStrong)
                    .foregroundStyle(OursColor.forest)
                footer
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(OursSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: OursRadius.md, style: .continuous)
                .fill(OursColor.surfaceBase)
                .oursElevation(.small, cornerRadius: OursRadius.md)
        }
        .accessibilityElement(children: .combine)
    }
}

/// What you co-own, at a glance: the item inside its share ring, its status in words, and who
/// you share it with.
///
/// Three pieces of information, none repeated. The ring shows how many places there are and
/// how many are taken; the status line says what is happening, in words ("1 place left",
/// "Full · we're buying it", "Ready to book"); the avatars say who. No status badges, no share
/// count and no money: the price lives on the detail screen. A badge or `action` appears only
/// when there is something to do, such as a compact "Book" button on an active coterie.
///
/// The card and its action are separate targets, never nested: `onOpen` opens the detail, the
/// action does its own thing. Pass co-owners only, never the viewer. A white card at
/// elevation small, radius 16, padding 12.
public struct OursOwnershipCard<Media: View, Action: View>: View {
    private let title: String
    private let status: String
    private let places: Int
    private let filled: Int
    private let coOwners: [OursAvatarGroup.Person]
    private let onOpen: () -> Void
    private let media: Media
    private let action: Action
    private let hasAction: Bool

    public init(
        title: String,
        status: String,
        places: Int,
        filled: Int,
        coOwners: [OursAvatarGroup.Person],
        onOpen: @escaping () -> Void,
        @ViewBuilder media: () -> Media,
        @ViewBuilder action: () -> Action
    ) {
        self.init(title: title, status: status, places: places, filled: filled, coOwners: coOwners,
                  onOpen: onOpen, media: media(), action: action(), hasAction: true)
    }

    init(
        title: String,
        status: String,
        places: Int,
        filled: Int,
        coOwners: [OursAvatarGroup.Person],
        onOpen: @escaping () -> Void,
        media: Media,
        action: Action,
        hasAction: Bool
    ) {
        self.title = title
        self.status = status
        self.places = places
        self.filled = filled
        self.coOwners = Array(coOwners.prefix(3))
        self.onOpen = onOpen
        self.media = media
        self.action = action
        self.hasAction = hasAction
    }

    public var body: some View {
        HStack(spacing: OursSpacing.md) {
            Button(action: onOpen) {
                HStack(spacing: OursSpacing.md) {
                    OursShareRing(places: places, filled: filled) { media }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .oursTextStyle(.bodyLargeStrong)
                            .foregroundStyle(OursColor.ink)
                            .lineLimit(2)
                        Text(status)
                            .oursTextStyle(.bodySmall)
                            .foregroundStyle(OursColor.slate)
                        if coOwners.isEmpty {
                            Text(OursShares.coOwnersPhrase([]))
                                .oursTextStyle(.bodySmall)
                                .foregroundStyle(OursColor.stone)
                                .padding(.top, OursSpacing.xxs)
                        } else {
                            OursAvatarGroup(people: coOwners, showsOpenPlace: false, style: .compact)
                                .padding(.top, OursSpacing.xxs)
                                .padding(.leading, OursStroke.strong)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if !hasAction {
                        Image(systemName: "chevron.right")
                            .font(.system(size: OursIconSize.sm, weight: .semibold))
                            .foregroundStyle(OursColor.slate)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(OursShares.cardLabel(title: title, status: status, coOwners: coOwners.map(\.name)))
            .accessibilityAddTraits(.isButton)

            if hasAction {
                action
            }
        }
        .padding(OursSpacing.sm)
        .background {
            RoundedRectangle(cornerRadius: OursRadius.md, style: .continuous)
                .fill(OursColor.surfaceBase)
                .oursElevation(.small, cornerRadius: OursRadius.md)
        }
    }
}

public extension OursOwnershipCard where Action == EmptyView {
    /// A card with no action of its own: a chevron shows it opens the detail.
    init(
        title: String,
        status: String,
        places: Int,
        filled: Int,
        coOwners: [OursAvatarGroup.Person],
        onOpen: @escaping () -> Void,
        @ViewBuilder media: () -> Media
    ) {
        self.init(title: title, status: status, places: places, filled: filled, coOwners: coOwners,
                  onOpen: onOpen, media: media(), action: EmptyView(), hasAction: false)
    }
}

public struct OursInformationCard: View {
    private let systemImage: String
    private let title: String
    private let detail: String

    public init(systemImage: String, title: String, detail: String) {
        self.systemImage = systemImage
        self.title = title
        self.detail = detail
    }

    public var body: some View {
        HStack(spacing: OursSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: OursIconSize.md))
                .foregroundStyle(OursColor.slate)
                .frame(width: OursSize.iconTile, height: OursSize.iconTile)
                .background(OursColor.sage, in: RoundedRectangle(cornerRadius: OursRadius.sm, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: OursSpacing.xxs) {
                Text(title)
                    .oursTextStyle(.bodyLargeStrong)
                    .foregroundStyle(OursColor.ink)
                Text(detail)
                    .oursTextStyle(.bodySmall)
                    .foregroundStyle(OursColor.slate)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(OursSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: OursRadius.md, style: .continuous)
                .fill(OursColor.surfaceAlt)
                .oursElevation(.none, cornerRadius: OursRadius.md)
        }
        .accessibilityElement(children: .combine)
    }
}
