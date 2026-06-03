import SwiftUI

struct TapPrisonView: View {
    @Binding var route: AppRoute
    @EnvironmentObject private var jail: JailController
    @Environment(\.scenePhase) private var scenePhase
    @State private var tapCount = 0

    var body: some View {
        VStack(spacing: 26) {
            Spacer(minLength: 24)

            VStack(spacing: 8) {
                Text("Pay the toll")
                    .font(.tapJail(13, weight: .bold))
                    .foregroundStyle(TapJailColor.red)
                    .textCase(.uppercase)

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

            Button {
                route = .lock
            } label: {
                Text("Back")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TapJailSecondaryButtonStyle())
            .padding(.horizontal, 24)
            .disabled(jail.isLockActive)
        }
        .padding(.vertical, 20)
        .background(TapJailColor.black)
        .onChange(of: scenePhase) { _, newPhase in
            guard tapCount < jail.tapTarget else { return }
            if newPhase == .inactive || newPhase == .background {
                tapCount = 0
            }
        }
    }

    private func registerTap() {
        guard tapCount < jail.tapTarget else { return }

        tapCount += 1

        if tapCount >= jail.tapTarget {
            jail.unlock()
            tapCount = 0
            route = .lock
        }
    }
}

struct ProgressDots: View {
    let count: Int
    let target: Int

    private let columns = Array(repeating: GridItem(.fixed(12), spacing: 6), count: 10)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(0..<target, id: \.self) { index in
                Circle()
                    .fill(index < count ? TapJailColor.red : TapJailColor.raised)
                    .frame(width: 12, height: 12)
            }
        }
        .frame(maxWidth: 174)
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
