import CoreGraphics

/// Spacing scale. A 4pt base grid with 8pt increments as the default rhythm.
///
/// `xs`, `md`, `lg` and `xl` — 8, 16, 24 and 32pt — cover 80%+ of the UI.
/// When in doubt, round to the nearest token.
public enum OursSpacing {
    /// 4pt — tiny gaps, icon spacing, hairlines. (`space2xs`)
    public static let xxs: CGFloat = 4
    /// 8pt — closely related elements, small gaps. (`spaceXs`)
    public static let xs: CGFloat = 8
    /// 12pt — label to supporting text, tight grouping. (`spaceSm`)
    public static let sm: CGFloat = 12
    /// 16pt — standard component padding, default gaps. (`spaceMd`)
    public static let md: CGFloat = 16
    /// 24pt — groups of related content, card padding. (`spaceLg`)
    public static let lg: CGFloat = 24
    /// 32pt — section spacing. (`spaceXl`)
    public static let xl: CGFloat = 32
    /// 48pt — large section separation. (`space2xl`)
    public static let xxl: CGFloat = 48
    /// 64pt — hero and editorial spacing. (`space3xl`)
    public static let xxxl: CGFloat = 64
}

/// Screen margins by layout density.
public enum OursScreenMargin {
    /// 16pt — dense utility screens.
    public static let dense: CGFloat = 16
    /// 24pt — the default, and editorial/onboarding screens.
    public static let standard: CGFloat = 24
}

/// Corner radius scale. Use `md` for the majority of surfaces; larger radii are reserved for
/// elevated or expressive moments.
public enum OursRadius {
    /// 4pt — progress tracks and other thin bars, where 8pt would round them into pills.
    public static let xxs: CGFloat = 4
    /// 8pt — small elements, inputs, chips.
    public static let xs: CGFloat = 8
    /// 12pt — buttons, small cards, alerts.
    public static let sm: CGFloat = 12
    /// 16pt — standard cards, inputs, sheets. The default.
    public static let md: CGFloat = 16
    /// 20pt — large cards and modals.
    public static let lg: CGFloat = 20
    /// 28pt — hero and onboarding cards.
    public static let xl: CGFloat = 28
}

/// Fixed sizes the system specifies rather than derives.
public enum OursSize {
    /// 56pt — standard height for primary, secondary and destructive buttons.
    public static let buttonHeight: CGFloat = 56
    /// 44pt — minimum interactive target in both dimensions.
    public static let minimumTouchTarget: CGFloat = 44
    /// 56pt — standard height for a single-line text field, matching `buttonHeight` so
    /// fields and the primary action below them share one rhythm.
    public static let fieldHeight: CGFloat = 56
    /// 24pt — horizontal padding inside a button.
    public static let buttonHorizontalPadding: CGFloat = 24

    /// 8pt — height of a progress track (funding bar, step segments).
    public static let progressTrack: CGFloat = 8
    /// 28pt — a small circular button laid over content, e.g. removing a photo. Sits inside a
    /// `minimumTouchTarget` hit area.
    public static let overlayButton: CGFloat = 28
    /// 32pt — an avatar.
    public static let avatar: CGFloat = 32
    /// 24pt — a compact avatar, overlapping in a row, as on the ownership card.
    public static let avatarCompact: CGFloat = 24
    /// 80pt — a share ring, including its stroke. The photo inside is 62.
    public static let shareRing: CGFloat = 80
    /// 48pt — a tile holding an icon beside text, as on the information card.
    public static let iconTile: CGFloat = 48
    /// 64pt — a disc holding a short figure such as a fraction, as on the ownership card.
    public static let figureDisc: CGFloat = 64
    /// 72pt — the disc holding a status icon on a full-screen state, e.g. the error screen.
    public static let statusDisc: CGFloat = 72
    /// 112pt — media thumbnail on a product card.
    public static let thumbnail: CGFloat = 112
    /// 160pt — default side of a photo tile.
    public static let photoTile: CGFloat = 160
    public static let chipLarge: CGFloat = 56
    public static let chipTile: CGFloat = 128
}

/// Point sizes for SF Symbols that stand on their own rather than scaling with text. A symbol
/// next to text uses `imageScale` instead, so it follows Dynamic Type.
///
/// `sm`, `md` and `lg` are steps of the §08 icon scale (16 · 20 · 24 · 32). `xs` sits below
/// it on purpose: it is only for a glyph inside a small control, where 16pt would crowd it.
public enum OursIconSize {
    /// 12pt — a glyph inside an `overlayButton`. Not a free-standing icon size.
    public static let xs: CGFloat = 12
    /// 16pt — small supporting indicators: chevrons, avatar placeholders, the open-place plus.
    public static let sm: CGFloat = 16
    /// 24pt — the default standard icon: in an `iconTile`, the plus on an empty photo tile.
    public static let md: CGFloat = 24
    /// 32pt — feature or prominent use: the icon in a `statusDisc`.
    public static let lg: CGFloat = 32
}

/// Stroke widths.
public enum OursStroke {
    /// 1pt — resting borders, hairlines and card edges.
    public static let hairline: CGFloat = 1
    /// 1.5pt — dashed outlines (an empty drop target) and the ring on an `overlayButton`.
    public static let medium: CGFloat = 1.5
    /// 2pt — a border that signals state: focus, error, success, a pressed secondary button.
    public static let strong: CGFloat = 2
    /// The dash of a dashed outline: 6pt on, 4pt off.
    public static let dash: [CGFloat] = [6, 4]
}
