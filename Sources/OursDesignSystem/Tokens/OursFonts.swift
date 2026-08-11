import CoreText
import Foundation

/// PostScript names of the bundled faces.
enum OursFontName: String {
    case serifRegular = "DMSerifDisplay-Regular"
    case serifItalic = "DMSerifDisplay-Italic"
    case interRegular = "Inter-Regular"
    case interSemiBold = "Inter-SemiBold"
    case interBold = "Inter-Bold"
}

/// Registers the bundled fonts with Core Text.
///
/// Fonts shipped inside a Swift package cannot be declared in the host app's `UIAppFonts`,
/// because that key can only see the app bundle. They must be registered at runtime from
/// `Bundle.module` instead. Registration happens automatically the first time a font token is
/// used, so callers do not normally need to do anything.
public enum OursFonts {

    /// Registers the bundled fonts. Idempotent, and safe to call from any thread.
    public static func registerIfNeeded() {
        _ = registered
    }

    /// Font file names as they appear in the resource bundle.
    private static let files = [
        "DMSerifDisplay-Regular",
        "DMSerifDisplay-Italic",
        "Inter-Regular",
        "Inter-SemiBold",
        "Inter-Bold"
    ]

    private static let registered: Bool = {
        var allSucceeded = true
        for name in files {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else {
                assertionFailure("Ours: font resource \(name).ttf missing from the package bundle")
                allSucceeded = false
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                // A font already registered by another copy of the bundle is not a failure.
                let code = CFErrorGetCode(error?.takeUnretainedValue())
                if code != CTFontManagerError.alreadyRegistered.rawValue {
                    assertionFailure("Ours: failed to register \(name).ttf — \(String(describing: error))")
                    allSucceeded = false
                }
            }
        }
        return allSucceeded
    }()
}
