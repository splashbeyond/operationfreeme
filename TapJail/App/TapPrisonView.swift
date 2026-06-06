import SwiftUI

struct TapPrisonView: View {
    @Binding var route: AppRoute
    @EnvironmentObject private var jail: JailController
    @Environment(\.scenePhase) private var scenePhase
    @State private var tapCount = 0

    private let accountabilityMessages = [
        "Still doomscrolling? Wow...",
        "Did you give up on your dreams?",
        "Like a rat hitting the dopamine button...",
        "This addiction is real...",
        "Wow. You said you were gonna be better.",
        "Your future self is watching this.",
        "Another tap for another broken promise.",
        "You came here because the phone won.",
        "Discipline would have been faster.",
        "Earn your way out."
    ]

    var body: some View {
        GeometryReader { proxy in
            prisonContent
                .frame(width: proxy.size.width, height: proxy.size.height)
                .padding(.vertical, 20)
                .overlay(alignment: .topLeading) {
                    backButton
                        .padding(.leading, 8)
                }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(TapJailColor.black)
            .onChange(of: scenePhase) { _, newPhase in
                guard tapCount < jail.tapTarget else { return }
                if newPhase == .inactive || newPhase == .background {
                    tapCount = 0
                }
            }
        }
    }

    private var prisonContent: some View {
        VStack(spacing: 26) {
            Spacer(minLength: 24)

            VStack(spacing: 8) {
                messageBox

                Text("\(tapCount)")
                    .font(.tapJail(88, weight: .bold))
                    .foregroundStyle(TapJailColor.white)
                    .contentTransition(.numericText())
                    .accessibilityLabel("\(tapCount) taps")

                Text("/ \(jail.tapTarget) taps to break out")
                    .font(.tapJail(15, weight: .light))
                    .foregroundStyle(TapJailColor.muted)
            }

            Button {
                registerTap()
            } label: {
                Circle()
                    .fill(TapJailColor.red)
                    .overlay(
                        Circle()
                            .stroke(TapJailColor.white.opacity(0.14), lineWidth: 2)
                    )
                    .frame(width: 240, height: 240)
                    .accessibilityLabel("Tap")
                    .accessibilityHint("Adds one tap toward breaking out of TapJail.")
            }
            .buttonStyle(TapCircleButtonStyle())

            ProgressDots(count: tapCount, target: jail.tapTarget)
                .padding(.horizontal, 10)

            Spacer(minLength: 24)
        }
    }

    private var messageBox: some View {
        Text(currentAccountabilityMessage)
            .font(.tapJailNote(30))
            .foregroundStyle(TapJailColor.white)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.68)
            .frame(maxWidth: 330, minHeight: 74)
            .padding(.horizontal, 26)
            .accessibilityLabel(currentAccountabilityMessage)
    }

    private var currentAccountabilityMessage: String {
        let messageIndex = min(tapCount / 10, accountabilityMessages.count - 1)
        return accountabilityMessages[messageIndex]
    }

    private var backButton: some View {
        Button {
            route = .lock
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(TapJailColor.white)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(TapJailIconButtonStyle())
        .accessibilityLabel("Back")
    }

    private func registerTap() {
        guard tapCount < jail.tapTarget else { return }

        tapCount += 1

        if tapCount >= jail.tapTarget {
            jail.completeBreakout()
            tapCount = 0
            route = .lock
        }
    }
}

struct ProgressDots: View {
    let count: Int
    let target: Int

    private let gridSize: CGFloat = 174

    private var rowCount: Int {
        let squareRoot = max(1, Int(Double(target).squareRoot()))

        for candidate in stride(from: squareRoot, through: 1, by: -1)
        where target.isMultiple(of: candidate) {
            return candidate
        }

        return 1
    }

    private var columnCount: Int {
        max(1, target / rowCount)
    }

    private var spacing: CGFloat {
        max(1.5, 6 * CGFloat((100 / Double(max(target, 1))).squareRoot()))
    }

    private var dotSize: CGFloat {
        let horizontalSpacing = spacing * CGFloat(columnCount - 1)
        let verticalSpacing = spacing * CGFloat(rowCount - 1)
        let widthBasedSize = (gridSize - horizontalSpacing) / CGFloat(columnCount)
        let heightBasedSize = (gridSize - verticalSpacing) / CGFloat(rowCount)
        return max(2, min(widthBasedSize, heightBasedSize))
    }

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.fixed(dotSize), spacing: spacing),
            count: columnCount
        )
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(0..<target, id: \.self) { index in
                Circle()
                    .fill(index < count ? TapJailColor.red : TapJailColor.raised)
                    .frame(width: dotSize, height: dotSize)
            }
        }
        .frame(width: gridSize, height: gridSize)
        .accessibilityLabel("\(count) of \(target) taps complete")
    }
}

struct TapCircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.easeInOut(duration: configuration.isPressed ? 0.08 : 0.12), value: configuration.isPressed)
    }
}

struct TapJailIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}
