import SwiftUI
import UIKit

/// The Ours colour palette.
///
/// Values are transcribed from the design system plates, with tokens darkened where needed to
/// meet the WCAG AA commitment the system makes. See `docs/design/ours-design-system.md` §01.
///
/// ## Appearance
/// Ours is light-only for now: the plates define no dark palette, and the app is pinned to
/// light with `.oursAppearance()`. Every token is still built so it *can* adapt. To give one
/// a dark value, write `Color(ours: light, dark: dark)` instead of `Color(ours: hex)`. The
/// contrast tests resolve every token in both appearances, so a dark value has to pass AA
/// before it ships. Once every token has one, remove the pin in `oursAppearance()`.
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
    /// Decorative borders and dividers: card hairlines, separators, progress tracks.
    ///
    /// Not for the edge of an interactive control. At 1.26:1 on white and 1.14:1 on cream it
    /// is below the 3:1 WCAG asks of a boundary someone needs to see to find the control. Use
    /// `outline` for that.
    public static let mist = Color(ours: 0xE5E5E7)
    /// Resting border of an interactive control: text fields, text areas, unselected chips.
    ///
    /// WCAG 1.4.11 asks 3:1 for the edge that identifies a control. A white field on cream is
    /// 1.11:1, so the border is the only thing marking it out. This measures 3.63:1 on white
    /// and 3.28:1 on cream. Cool-tinted like `mist` and `slate`, so it sits in the neutrals.
    public static let outline = Color(ours: 0x86868A)
    /// Border of a focused input, and the text caret.
    ///
    /// §11 asks for "a lavender border" when focused, but the palette's lavenders are all
    /// pale backing tints that measure about 1.2:1 on a white field. This keeps the violet
    /// hue at 4.65:1, darkened from `#9D87DC` (3.03:1) once resting fields took the
    /// 3.63:1 `outline`: focus must read as the stronger state, not the lighter one.
    public static let focus = Color(ours: 0x7E61D1)

    // MARK: Surfaces

    /// Cards, sheets and the navigation bar.
    public static let surfaceBase = Color(ours: 0xFFFFFF)
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
    /// Builds a colour from a 24-bit RGB literal, e.g. `0x0F3D34`, the same in light and dark.
    init(ours hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    /// Builds a colour that resolves to `light` or `dark` with the interface style.
    init(ours light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(ours: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension UIColor {
    convenience init(ours hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

public extension View {
    /// Applies the appearance Ours supports. Put it once, on the app's root view.
    ///
    /// Ours has no dark palette yet, so this pins the light colour scheme: without it, system
    /// controls, sheets and materials turn dark around tokens that do not, and text in a
    /// system component can land on the wrong ground. When every token has a dark value,
    /// this becomes a no-op and the system follows the device.
    func oursAppearance() -> some View {
        preferredColorScheme(.light)
    }
}
