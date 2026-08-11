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

private func contrast(_ a: Color, _ b: Color) -> Double {
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
                             ("periwinkle", OursColor.periwinkle),
                             ("yellow", OursColor.yellow)] {
            #expect(contrast(OursColor.ink, fill) >= 4.5, "ink on \(name)")
            #expect(contrast(OursColor.forest, fill) >= 4.5, "forest on \(name)")
        }
    }

    /// Lavender and yellow are fill-only. If either ever passes as text on white, someone has
    /// darkened it and the "fill only" rule in the design system needs revisiting.
    @Test func brandFillsRemainUnusableAsTextOnWhite() {
        #expect(contrast(OursColor.yellow, .white) < 3.0)
        #expect(contrast(OursColor.lavender, .white) < 3.0)
        #expect(contrast(OursColor.periwinkle, .white) < 3.0)
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
    }

    @Test func serifIsReservedForHeadlines() {
        for style in [OursTextStyle.display, .h1, .h2] {
            #expect(style.fontName == .instrumentSerifRegular)
        }
        for style in [OursTextStyle.h3, .bodyLarge, .body, .bodySmall, .caption, .button] {
            #expect(style.fontName != .instrumentSerifRegular, "\(style) should use Inter")
        }
    }
}

// MARK: - Fonts

struct FontRegistrationTests {
    @Test func bundledFontsRegisterAndResolve() {
        OursFonts.registerIfNeeded()
        for name in [
            OursFontName.instrumentSerifRegular,
            .instrumentSerifItalic,
            .interRegular,
            .interSemiBold
        ] {
            let font = UIFont(name: name.rawValue, size: 17)
            #expect(font != nil, "\(name.rawValue) did not resolve — registration failed")
            #expect(font?.fontName == name.rawValue)
        }
    }

    /// Catches a resource being dropped from the package manifest.
    @Test func everyFontFileIsPresentInTheBundle() {
        for name in ["InstrumentSerif-Regular", "InstrumentSerif-Italic",
                     "Inter-Regular", "Inter-SemiBold"] {
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
