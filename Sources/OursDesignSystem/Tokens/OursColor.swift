import SwiftUI

/// The Ours colour palette.
///
/// Values are transcribed from the design system plates, with three tokens darkened to meet
/// the WCAG AA commitment the system makes. See `docs/design/ours-design-system.md` §01.
public enum OursColor {

    // MARK: Brand

    /// Primary brand colour. Key actions, active states, brand expression.
    public static let forest = Color(ours: 0x0F3D34)
    /// App background and soft warm surfaces.
    public static let cream = Color(ours: 0xF6F3EE)
    /// Highlights, feature surfaces and moments of delight. Fill only — never text.
    public static let lavender = Color(ours: 0xE9E6FF)
    /// Attention badges and small accents. Fill only — 1.34:1 against white.
    public static let yellow = Color(ours: 0xF2E074)
    /// A deeper lilac for decorative surfaces that must read as purple against `cream`.
    /// `lavender` is nearly white and disappears on the app background; use this where the
    /// surface itself is the visual rather than a backdrop for content. Fill only.
    public static let lavenderDeep = Color(ours: 0xE4D6F7)
    /// Secondary feature surface, paired with `lavenderDeep` in layered compositions.
    /// Fill only. Reinstated for the onboarding card stack; never use it to distinguish a
    /// state from `lavender`, which it is too close to in value.
    public static let periwinkle = Color(ours: 0xC9D3F3)

    /// Pale sage. A decorative backing surface, paired with `peach`. Fill only.
    /// A one-off rather than part of a scale — there is no other green tint in the system.
    public static let sage = Color(ours: 0xE1EAE1)
    /// Warm peach. A decorative backing surface, paired with `sage`. Fill only.
    public static let peach = Color(ours: 0xF9EBDB)

    // MARK: Neutrals

    /// Primary text.
    public static let ink = Color(ours: 0x111111)
    /// Secondary text.
    public static let slate = Color(ours: 0x4B4B4F)
    /// Tertiary text, metadata, placeholders. Darkened from the plate's `#A3A3A3`, which
    /// measured 2.28:1 on cream.
    public static let stone = Color(ours: 0x6E6E6E)
    /// Borders and dividers.
    public static let mist = Color(ours: 0xE5E5E7)
    /// Border of a focused input.
    ///
    /// §11 asks for "a lavender border" when focused, but the palette's lavenders are all
    /// pale backing tints. `lavender` measures 1.22:1 on a white field and `mist` — the
    /// resting border — measures 1.26:1, so swapping one for the other changes the hue and
    /// almost nothing else; the focused state would not read as a state. At 3.03:1 this does.
    ///
    /// Like `info`, it sits on the minimum with no headroom. Darkening it is safe; lightening
    /// it is not.
    public static let focus = Color(ours: 0x9D87DC)

    // MARK: Surfaces

    /// Cards, sheets and the navigation bar.
    public static let surfaceBase = Color.white
    /// Grouped and secondary backgrounds.
    public static let surfaceAlt = cream
    /// Main app background.
    public static let backgroundPrimary = cream

    // MARK: Semantic

    /// Success and confirmation. Deliberately distinct from `forest`.
    public static let success = Color(ours: 0x1E7A5E)
    /// Warning and caution. Darkened from the plate's `#D4A017`, which measured 2.38:1.
    public static let warning = Color(ours: 0x8A6410)
    /// Errors and destructive actions.
    public static let error = Color(ours: 0xC62828)
    /// Neutral informational messages. Darkened from the plate's `#557C8A`, which measured
    /// 4.09:1 on cream. At 4.51:1 this is the minimum passing value and has no headroom.
    public static let info = Color(ours: 0x507582)

    // MARK: Fills

    /// Pale fill behind a destructive button in its resting state.
    public static let errorSurface = Color(ours: 0xFBEBEB)
    /// Disabled control fill.
    public static let disabled = Color(ours: 0xE5E5E7)
}

extension Color {
    /// Builds a colour from a 24-bit RGB literal, e.g. `0x0F3D34`.
    init(ours hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
