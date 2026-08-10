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
    /// 24pt — horizontal padding inside a button.
    public static let buttonHorizontalPadding: CGFloat = 24
}
