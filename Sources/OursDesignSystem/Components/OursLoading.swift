import SwiftUI

/// Delays showing its content, so work that is usually instant does not flash a spinner.
///
/// §14's don'ts include *don't block the user unnecessarily*. A spinner that appears and
/// vanishes inside 100ms reads as a glitch — worse than showing nothing — but the same work
/// on a slow connection needs to say something. This shows nothing until the wait is long
/// enough to be worth explaining.
public struct OursDelayed<Content: View>: View {
    private let delay: Duration
    private let content: () -> Content

    @State private var isVisible = false

    /// - Parameter delay: how long to stay silent. The default is roughly the point at which
    ///   a wait stops feeling instant.
    public init(by delay: Duration = OursMotion.feedbackDelay, @ViewBuilder content: @escaping () -> Content) {
        self.delay = delay
        self.content = content
    }

    public var body: some View {
        ZStack {
            if isVisible {
                content()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            withAnimation(OursMotion.standardEaseOut) { isVisible = true }
        }
    }
}

/// A spinner for a short, isolated wait, with room to say what is being waited on.
///
/// §14 reserves skeletons for structured content — lists, cards, galleries — and spinners for
/// isolated actions. Use this for the latter.
public struct OursSpinner: View {
    private let title: String?
    private let detail: String?

    public init(_ title: String? = nil, detail: String? = nil) {
        self.title = title
        self.detail = detail
    }

    public var body: some View {
        VStack(spacing: OursSpacing.md) {
            ProgressView()
                .controlSize(.large)
                .tint(OursColor.forest)

            if title != nil || detail != nil {
                VStack(spacing: OursSpacing.xxs) {
                    if let title {
                        Text(title)
                            .oursTextStyle(.bodyLargeStrong)
                            .foregroundStyle(OursColor.ink)
                    }
                    if let detail {
                        Text(detail)
                            .oursTextStyle(.bodySmall)
                            .foregroundStyle(OursColor.stone)
                    }
                }
                .multilineTextAlignment(.center)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title ?? "Loading")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

/// A whole screen that could not load, with a way back to trying again.
///
/// §14 prefers contextual errors over full screen ones — but when the screen's entire content
/// is what failed, this *is* the context. Always offers a retry; the secondary way out is
/// optional because not every screen has somewhere to go back to.
public struct OursErrorScreen: View {
    private let title: String
    private let message: String
    private let retryTitle: String
    private let onRetry: () -> Void
    private let dismissTitle: String?
    private let onDismiss: (() -> Void)?

    public init(
        title: String = "Something went wrong",
        message: String,
        retryTitle: String = "Try again",
        onRetry: @escaping () -> Void,
        dismissTitle: String? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
        self.dismissTitle = dismissTitle
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: OursSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: OursIconSize.lg))
                .foregroundStyle(OursColor.error)
                .frame(width: OursSize.statusDisc, height: OursSize.statusDisc)
                .background(OursColor.errorSurface, in: Circle())
                .accessibilityHidden(true)

            VStack(spacing: OursSpacing.xs) {
                Text(title)
                    .oursTextStyle(.h3)
                    .foregroundStyle(OursColor.ink)
                Text(message)
                    .oursTextStyle(.body)
                    .foregroundStyle(OursColor.slate)
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            OursButton(retryTitle, action: onRetry)
                .padding(.top, OursSpacing.xs)

            if let dismissTitle, let onDismiss {
                OursButton(dismissTitle, kind: .tertiary, action: onDismiss)
            }
        }
        .padding(.horizontal, OursScreenMargin.standard)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
