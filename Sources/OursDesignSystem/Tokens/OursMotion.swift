import SwiftUI

/// Motion durations and the animations built from them.
///
/// Motion is subtle, purposeful and consistent. Respect Reduce Motion by simplifying or
/// removing non-essential movement — `oursAnimation(_:reduceMotion:)` does this for you.
public enum OursMotion {
    /// ~150ms — micro-interactions and press feedback.
    public static let quick: TimeInterval = 0.15
    /// ~250ms — most UI changes and transitions.
    public static let standard: TimeInterval = 0.25
    /// ~400ms — emphasis and complex motion.
    public static let expressive: TimeInterval = 0.40

    /// How long to show nothing before acknowledging a wait. Below this a wait still feels
    /// instant, and a spinner that flashes reads as a glitch. Used by `OursDelayed`.
    public static let feedbackDelay: Duration = .milliseconds(400)

    /// Scale applied to a control while pressed.
    public static let pressedScale: CGFloat = 0.98

    public static var quickEaseOut: Animation { .easeOut(duration: quick) }
    public static var standardEaseOut: Animation { .easeOut(duration: standard) }
    public static var standardEaseInOut: Animation { .easeInOut(duration: standard) }
    public static var expressiveEaseOut: Animation { .easeOut(duration: expressive) }

    /// Returns `animation`, or `nil` when Reduce Motion is enabled so the change is instant.
    public static func respectingReduceMotion(
        _ animation: Animation,
        reduceMotion: Bool
    ) -> Animation? {
        reduceMotion ? nil : animation
    }
}
