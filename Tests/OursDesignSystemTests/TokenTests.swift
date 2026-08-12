import Testing
import SwiftUI
import UIKit
@testable import OursDesignSystem

// MARK: - Contrast

/// Relative luminance per WCAG 2.1.
private func luminance(_ color: Color) -> Double {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
    func channel(_ value: CGFloat) -> Double {
        let v = Double(value)
        return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
    }
    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
}

func contrast(_ a: Color, _ b: Color) -> Double {
    let (la, lb) = (luminance(a), luminance(b))
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
}

/// Guards the palette against a well-meaning tweak that quietly breaks readability.
/// The design system commits to WCAG AA — 4.5:1 for body text, 3:1 for large text and UI.
struct ContrastTests {
    private static let bodyText: [(String, Color)] = [
        ("ink", OursColor.ink),
        ("slate", OursColor.slate),
        ("stone", OursColor.stone),
        ("forest", OursColor.forest),
        ("success", OursColor.success),
        ("warning", OursColor.warning),
        ("error", OursColor.error),
        ("info", OursColor.info)
    ]

    @Test(arguments: bodyText)
    func textTokensMeetAAOnBothGrounds(_ token: (name: String, color: Color)) {
        for (groundName, ground) in [
            ("backgroundPrimary", OursColor.backgroundPrimary),
            ("surfaceBase", OursColor.surfaceBase)
        ] {
            let ratio = contrast(token.color, ground)
            #expect(
                ratio >= 4.5,
                "\(token.name) on \(groundName) is \(String(format: "%.2f", ratio)):1, below AA 4.5"
            )
        }
    }

    @Test func whiteLabelsOnFilledButtonsMeetAA() {
        for (name, fill) in [("forest", OursColor.forest), ("error", OursColor.error)] {
            let ratio = contrast(.white, fill)
            #expect(ratio >= 4.5, "white on \(name) is \(String(format: "%.2f", ratio)):1")
        }
    }

    @Test func textOnBrandFillsMeetsAA() {
        for (name, fill) in [("lavender", OursColor.lavender),
                             ("lavenderDeep", OursColor.lavenderDeep),
                             ("periwinkle", OursColor.periwinkle),
                             ("sage", OursColor.sage),
                             ("peach", OursColor.peach),
                             ("yellow", OursColor.yellow)] {
            #expect(contrast(OursColor.ink, fill) >= 4.5, "ink on \(name)")
            #expect(contrast(OursColor.forest, fill) >= 4.5, "forest on \(name)")
            // Secondary text passes over these too, now that the sign-up decoration drifts
            // its shapes underneath the copy.
            #expect(contrast(OursColor.slate, fill) >= 4.5, "slate on \(name)")
        }
    }

    /// Lavender and yellow are fill-only. If either ever passes as text on white, someone has
    /// darkened it and the "fill only" rule in the design system needs revisiting.
    @Test func brandFillsRemainUnusableAsTextOnWhite() {
        #expect(contrast(OursColor.yellow, .white) < 3.0)
        #expect(contrast(OursColor.lavender, .white) < 3.0)
        #expect(contrast(OursColor.periwinkle, .white) < 3.0)
        #expect(contrast(OursColor.lavenderDeep, .white) < 3.0)
        #expect(contrast(OursColor.sage, .white) < 3.0)
        #expect(contrast(OursColor.peach, .white) < 3.0)
    }
}

// MARK: - Typography

struct TypographyTests {
    @Test func everyStyleHasNonNegativeLineSpacing() {
        for style in OursTextStyle.allCases {
            #expect(style.lineSpacing >= 0, "\(style) has negative line spacing")
        }
    }

    @Test func lineHeightsMatchTheSpecifiedScale() {
        #expect(OursTextStyle.display.lineHeight == 48)
        #expect(OursTextStyle.h1.lineHeight == 40)
        #expect(OursTextStyle.body.lineHeight == 22)
        #expect(OursTextStyle.caption.lineHeight == 16)
        #expect(OursTextStyle.button.lineHeight == nil)
        #expect(OursTextStyle.bodyLargeStrong.lineHeight == OursTextStyle.bodyLarge.lineHeight)
    }

    @Test func serifIsReservedForHeadlines() {
        for style in [OursTextStyle.display, .h1, .h2] {
            #expect(style.fontName == .serifRegular)
        }
        for style in [OursTextStyle.h3, .bodyLarge, .bodyLargeStrong, .body,
                      .bodySmall, .caption, .button] {
            #expect(style.fontName != .serifRegular, "\(style) should use Inter")
        }
    }
}

// MARK: - Fonts

struct FontRegistrationTests {
    @Test func bundledFontsRegisterAndResolve() {
        OursFonts.registerIfNeeded()
        for name in [
            OursFontName.serifRegular,
            .serifItalic,
            .interRegular,
            .interSemiBold,
            .interBold
        ] {
            let font = UIFont(name: name.rawValue, size: 17)
            #expect(font != nil, "\(name.rawValue) did not resolve — registration failed")
            #expect(font?.fontName == name.rawValue)
        }
    }

    /// Catches a resource being dropped from the package manifest.
    @Test func everyFontFileIsPresentInTheBundle() {
        for name in ["DMSerifDisplay-Regular", "DMSerifDisplay-Italic",
                     "Inter-Regular", "Inter-SemiBold", "Inter-Bold"] {
            #expect(
                Bundle.module.url(forResource: name, withExtension: "ttf") != nil,
                "\(name).ttf missing from the resource bundle"
            )
        }
    }
}

// MARK: - Layout

struct LayoutTests {
    @Test func spacingScaleFollowsTheFourPointGrid() {
        let scale: [CGFloat] = [
            OursSpacing.xxs, OursSpacing.xs, OursSpacing.sm, OursSpacing.md,
            OursSpacing.lg, OursSpacing.xl, OursSpacing.xxl, OursSpacing.xxxl
        ]
        for value in scale {
            #expect(value.truncatingRemainder(dividingBy: 4) == 0, "\(value) is off the 4pt grid")
        }
    }

    @Test func touchTargetsMeetTheMinimum() {
        #expect(OursSize.minimumTouchTarget >= 44)
        #expect(OursSize.buttonHeight >= OursSize.minimumTouchTarget)
    }
}

// MARK: - Buttons

/// `.foregroundStyle` is silently ignored on `OursButton` because the style sets the label
/// colour on its own content. These pin the supported override instead.
struct ButtonColourTests {
    @Test func eachKindHasItsOwnRestingLabelColour() {
        #expect(OursButtonKind.primary.labelColor(pressed: false, isEnabled: true, override: nil) == .white)
        #expect(OursButtonKind.secondary.labelColor(pressed: false, isEnabled: true, override: nil) == OursColor.forest)
        #expect(OursButtonKind.tertiary.labelColor(pressed: false, isEnabled: true, override: nil) == OursColor.forest)
        #expect(OursButtonKind.destructive.labelColor(pressed: false, isEnabled: true, override: nil) == OursColor.error)
    }

    @Test func destructiveInvertsWhilePressed() {
        #expect(OursButtonKind.destructive.labelColor(pressed: true, isEnabled: true, override: nil) == .white)
    }

    @Test(arguments: [OursButtonKind.primary, .secondary, .tertiary, .destructive])
    func overrideReplacesTheLabelColour(_ kind: OursButtonKind) {
        #expect(kind.labelColor(pressed: false, isEnabled: true, override: OursColor.stone) == OursColor.stone)
    }

    /// A caller tinting a label must not be able to make an unusable control look usable.
    @Test(arguments: [OursButtonKind.primary, .secondary, .tertiary, .destructive])
    func disabledIgnoresTheOverride(_ kind: OursButtonKind) {
        #expect(kind.labelColor(pressed: false, isEnabled: false, override: OursColor.forest) == OursColor.stone)
    }

    @Test func onlyTertiaryIsNotFullWidth() {
        #expect(OursButtonKind.tertiary.isFullWidth == false)
        for kind in [OursButtonKind.primary, .secondary, .destructive] {
            #expect(kind.isFullWidth)
        }
    }

    @Test func filledKindsMeetContrastWithTheirLabel() {
        for kind in [OursButtonKind.primary, .destructive] {
            let label = kind.labelColor(pressed: false, isEnabled: true, override: nil)
            let fill = kind.backgroundColor(pressed: false, isEnabled: true)
            #expect(contrast(label, fill) >= 4.5, "\(kind) label on its own fill")
        }
    }
}

// MARK: - Text fields

struct TextFieldBorderTests {
    @Test func restingFieldsUseTheHairlineBorder() {
        #expect(OursTextFieldBorder.color(state: .neutral, isFocused: false, isEnabled: true) == OursColor.mist)
        #expect(OursTextFieldBorder.width(state: .neutral, isFocused: false) == 1)
    }

    @Test func focusIsVisible() {
        #expect(OursTextFieldBorder.color(state: .neutral, isFocused: true, isEnabled: true) == OursColor.focus)
        #expect(OursTextFieldBorder.width(state: .neutral, isFocused: true) == 2)
    }

    /// A field the user is fixing must keep showing what is wrong while they type in it.
    @Test func errorOutranksFocus() {
        #expect(OursTextFieldBorder.color(state: .error("bad"), isFocused: true, isEnabled: true) == OursColor.error)
    }

    /// The moment a field comes right is while it is still focused. If focus outranked
    /// success, the confirmation would only appear after the user had already moved on.
    @Test func successOutranksFocus() {
        #expect(OursTextFieldBorder.color(state: .success(), isFocused: true, isEnabled: true) == OursColor.success)
        #expect(OursTextFieldBorder.width(state: .success(), isFocused: false) == 2)
    }

    /// A disabled field never draws attention, even if its state is stale.
    @Test func disabledStaysNeutral() {
        for state in [OursFieldState.neutral, .error("bad"), .success()] {
            #expect(OursTextFieldBorder.color(state: state, isFocused: true, isEnabled: false) == OursColor.mist)
        }
    }

    @Test func onlyStatesCarryingAMessageExposeOne() {
        #expect(OursFieldState.neutral.message == nil)
        #expect(OursFieldState.error("bad").message == "bad")
        #expect(OursFieldState.success().message == nil)
        #expect(OursFieldState.success("Looks good").message == "Looks good")
    }

    /// The reason `focus` exists rather than reusing `lavender`: a border is UI, so it owes
    /// 3:1 against the field it outlines.
    @Test func focusBorderMeetsUIContrast() {
        let ratio = contrast(OursColor.focus, OursColor.surfaceBase)
        #expect(ratio >= 3.0, "focus on surfaceBase is \(String(format: "%.2f", ratio)):1")
        #expect(contrast(OursColor.lavender, OursColor.surfaceBase) < 3.0, "lavender would not have")
    }

    /// Error and success borders are the other two state signals, and owe the same 3:1.
    @Test func stateBordersMeetUIContrast() {
        for (name, color) in [("error", OursColor.error), ("success", OursColor.success)] {
            let ratio = contrast(color, OursColor.surfaceBase)
            #expect(ratio >= 3.0, "\(name) on surfaceBase is \(String(format: "%.2f", ratio)):1")
        }
    }
}

// MARK: - Feedback

/// §14: "never rely on colour alone to convey meaning" — and the colour has to be readable
/// on the surface it sits on.
struct MessageBannerTests {
    @Test(arguments: OursMessageTone.allCases)
    func everyToneCarriesAnIconAndAWordAsWellAsAColour(_ tone: OursMessageTone) {
        #expect(!tone.symbol.isEmpty)
        #expect(!tone.accessibilityPrefix.isEmpty)
    }

    @Test(arguments: OursMessageTone.allCases)
    func everyToneIsLegibleOnItsOwnSurface(_ tone: OursMessageTone) {
        let ratio = contrast(tone.foreground, tone.background)
        #expect(ratio >= 4.5, "\(tone) is \(String(format: "%.2f", ratio)):1 on its own fill")
    }

    /// The banner sits on the app background as often as on a card, so it must survive both.
    @Test(arguments: OursMessageTone.allCases)
    func everyToneIsLegibleOnTheAppBackground(_ tone: OursMessageTone) {
        #expect(contrast(tone.foreground, OursColor.backgroundPrimary) >= 4.5)
    }

    /// Two tones that look alike defeat the point of having tones.
    @Test func tonesAreVisuallyDistinct() {
        let foregrounds = OursMessageTone.allCases.map(\.foreground)
        #expect(Set(foregrounds).count == OursMessageTone.allCases.count)
        let symbols = OursMessageTone.allCases.map(\.symbol)
        #expect(Set(symbols).count == OursMessageTone.allCases.count)
    }
}
