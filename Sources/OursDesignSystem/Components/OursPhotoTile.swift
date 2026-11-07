import SwiftUI

public struct OursPhotoTile: View {
    public enum Content {
        case add(title: String, detail: String)
        case preparing
        case photo(Image, onRemove: (() -> Void)?)
    }

    private let content: Content
    private let side: CGFloat

    public init(_ content: Content, side: CGFloat = 160) {
        self.content = content
        self.side = side
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: OursRadius.md, style: .continuous)
    }

    public var body: some View {
        tile
            .frame(width: side, height: side)
    }

    @ViewBuilder
    private var tile: some View {
        switch content {
        case .add(let title, let detail):
            addTile(title: title, detail: detail)
        case .preparing:
            ProgressView()
                .tint(OursColor.forest)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(OursColor.surfaceAlt, in: shape)
                .oursElevation(.none, cornerRadius: OursRadius.md)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Preparing photo")
        case .photo(let image, let onRemove):
            photoTile(image: image, onRemove: onRemove)
        }
    }

    private func addTile(title: String, detail: String) -> some View {
        VStack(spacing: OursSpacing.xxs) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(OursColor.forest)
                .accessibilityHidden(true)
            Text(title)
                .oursTextStyle(.bodyLargeStrong)
                .foregroundStyle(OursColor.ink)
            Text(detail)
                .oursTextStyle(.bodySmall)
                .foregroundStyle(OursColor.stone)
        }
        .multilineTextAlignment(.center)
        .minimumScaleFactor(0.6)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .padding(OursSpacing.xs)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OursColor.surfaceBase, in: shape)
        .overlay {
            shape.strokeBorder(
                OursColor.stone,
                style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
            )
        }
        .accessibilityElement(children: .combine)
    }

    private func photoTile(image: Image, onRemove: (() -> Void)?) -> some View {
        image
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(OursColor.surfaceAlt)
            .clipShape(shape)
            .oursElevation(.none, cornerRadius: OursRadius.md)
            .overlay(alignment: .topTrailing) {
                if let onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(OursColor.forest, in: Circle())
                            .overlay { Circle().strokeBorder(.white, lineWidth: 1.5) }
                            .frame(
                                width: OursSize.minimumTouchTarget,
                                height: OursSize.minimumTouchTarget
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove photo")
                }
            }
    }
}
