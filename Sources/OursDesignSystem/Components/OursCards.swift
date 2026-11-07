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

/// The ownership card's fraction disc. Outside the generic card so it can be tested.
///
/// `forest` with a white figure: the fraction is what the card is about, and the brand colour
/// makes it the first thing read. The disc was `lavenderDeep` on the `lavender` card, 1.13:1,
/// so its edge was all but invisible and the figure floated.
enum OursOwnershipDisc {
    static let fill = OursColor.forest
    static let label = Color.white
}

public struct OursOwnershipCard<Status: View>: View {
    private let fraction: String
    private let title: String
    private let detail: String
    private let showsChevron: Bool
    private let status: Status

    public init(
        fraction: String,
        title: String,
        detail: String,
        showsChevron: Bool,
        @ViewBuilder status: () -> Status
    ) {
        self.fraction = fraction
        self.title = title
        self.detail = detail
        self.showsChevron = showsChevron
        self.status = status()
    }

    public var body: some View {
        HStack(spacing: OursSpacing.md) {
            Text(fraction)
                .oursTextStyle(.h3)
                .foregroundStyle(OursOwnershipDisc.label)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .frame(width: OursSize.figureDisc, height: OursSize.figureDisc)
                .background(OursOwnershipDisc.fill, in: Circle())

            VStack(alignment: .leading, spacing: OursSpacing.xxs) {
                Text(title)
                    .oursTextStyle(.bodyLargeStrong)
                    .foregroundStyle(OursColor.ink)
                Text(detail)
                    .oursTextStyle(.bodySmall)
                    .foregroundStyle(OursColor.slate)
                status
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: OursIconSize.sm, weight: .semibold))
                    .foregroundStyle(OursColor.slate)
                    .accessibilityHidden(true)
            }
        }
        .padding(OursSpacing.md)
        .background(OursColor.lavender, in: RoundedRectangle(cornerRadius: OursRadius.md, style: .continuous))
        .accessibilityElement(children: .combine)
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
