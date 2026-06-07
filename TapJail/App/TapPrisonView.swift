import SwiftUI

enum EmotionalLevel: String, CaseIterable, Identifiable {
    case inspirational
    case nice
    case normal
    case sortaMean
    case rager

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inspirational: return "Inspirational"
        case .nice: return "Nice"
        case .normal: return "Normal"
        case .sortaMean: return "Sorta Mean"
        case .rager: return "Rager"
        }
    }

    var description: String {
        switch self {
        case .inspirational:
            return "Encouraging wins, perspective, and reasons to put the phone down."
        case .nice:
            return "Supportive accountability with a gentle push."
        case .normal:
            return "Direct screen-time facts without sugarcoating."
        case .sortaMean:
            return "Sharp, sarcastic, and intentionally uncomfortable."
        case .rager:
            return "Maximum-volume tough love. Expect yelling."
        }
    }
}

private struct PrisonMessageSet {
    let progress: [String]
    let milestones: [String]
}

struct TapPrisonView: View {
    @Binding var route: AppRoute
    @EnvironmentObject private var jail: JailController
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(
        TapJailConstants.StorageKey.emotionalLevel,
        store: UserDefaults(suiteName: TapJailConstants.appGroupID)
    ) private var emotionalLevelRawValue = EmotionalLevel.sortaMean.rawValue
    @State private var tapCount = 0

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
            .contentTransition(.opacity)
            .animation(.easeInOut(duration: 0.18), value: currentAccountabilityMessage)
            .accessibilityLabel(currentAccountabilityMessage)
    }

    private var currentAccountabilityMessage: String {
        let messages = messageSet

        if tapCount >= 100 {
            let milestoneIndex = min((tapCount / 100) - 1, messages.milestones.count - 1)
            return messages.milestones[milestoneIndex]
        }

        let messageIndex = min(tapCount / 10, messages.progress.count - 1)
        return messages.progress[messageIndex]
    }

    private var emotionalLevel: EmotionalLevel {
        EmotionalLevel(rawValue: emotionalLevelRawValue) ?? .sortaMean
    }

    private var messageSet: PrisonMessageSet {
        switch emotionalLevel {
        case .inspirational:
            return PrisonMessageSet(
                progress: [
                    "You noticed the habit. That is where change starts.",
                    "Ten taps noticed. You can stop before eleven.",
                    "Roger Bannister broke the four-minute mile. Your next win can be walking away.",
                    "Thirty taps is enough time to choose a better next move.",
                    "Your attention belongs to you. Take it back now.",
                    "Less scrolling leaves more room for sleep, people, and joy.",
                    "Sixty taps noticed. The strongest move is stopping here.",
                    "Apollo 11 reached the Moon in about three days. Give today to something memorable.",
                    "Eighty taps is a loud signal that this app can wait.",
                    "Your future self benefits the moment you put the phone down."
                ],
                milestones: [
                    "100 taps. Make this the moment you choose your day instead.",
                    "200 taps. You can end the loop right now.",
                    "300 taps. Put this persistence toward something you care about.",
                    "400 taps. Your attention can still return to the life around you.",
                    "500 taps. Stop here and make the second half of this moment yours.",
                    "600 taps. Habits change when the next repetition does not happen.",
                    "700 taps. You are still in control. Prove it by leaving.",
                    "800 taps. The app can wait. Your time cannot.",
                    "900 taps. The best ending is closing TapJail right now."
                ]
            )
        case .nice:
            return PrisonMessageSet(
                progress: [
                    "Take a breath. Do you really need the app?",
                    "It is okay to put the phone down.",
                    "You set this limit for a reason.",
                    "A small pause can break a big habit.",
                    "Your time is worth protecting.",
                    "Maybe the app can wait a little longer.",
                    "You are allowed to choose something better.",
                    "This is a good moment to reconsider.",
                    "You do not owe every notification your attention.",
                    "Ninety taps is plenty. Be kind to yourself and stop."
                ],
                milestones: [
                    "100 taps. Still sure this is worth your time?",
                    "200 taps. You can stop whenever you choose.",
                    "300 taps. That is a lot of effort for one app.",
                    "400 taps. Your time may be better spent elsewhere.",
                    "500 taps. Pause here and check in with yourself.",
                    "600 taps. The app will still be there later.",
                    "700 taps. You have another chance to put the phone down.",
                    "800 taps. Choosing to stop is still available.",
                    "900 taps. Be honest about what you need, then walk away."
                ]
            )
        case .normal:
            return PrisonMessageSet(
                progress: [
                    "Your daily limit has been reached.",
                    "Frequent checking makes focused work harder.",
                    "Endless feeds are designed to keep you scrolling.",
                    "Notifications compete for your attention.",
                    "Screen time can quietly replace sleep and movement.",
                    "The app is not urgent just because it is available.",
                    "Habit loops get stronger when they are automatic.",
                    "This pause gives you time to make a deliberate choice.",
                    "More screen time does not usually mean more satisfaction.",
                    "Continuing reinforces the loop. Stopping interrupts it."
                ],
                milestones: [
                    "100 taps. The extra screen time now has a real cost.",
                    "200 taps. Repetition is reinforcing the habit.",
                    "300 taps. This is three hundred choices to continue.",
                    "400 taps. Your attention is still being spent.",
                    "500 taps. The healthiest next tap is no tap.",
                    "600 taps. Consider whether the app solves a real need.",
                    "700 taps. Automatic use is exactly what this pause interrupts.",
                    "800 taps. More tapping means more time committed to the habit.",
                    "900 taps. Stop now instead of extending today's screen time."
                ]
            )
        case .sortaMean:
            return PrisonMessageSet(
                progress: [
                    "Still doomscrolling? Wow...",
                    "Did you give up on your dreams?",
                    "Like a rat hitting the dopamine button...",
                    "This addiction is real...",
                    "Wow. You said you were gonna be better.",
                    "Your future self is watching this.",
                    "Another tap for another broken promise.",
                    "You came here because the phone won.",
                    "Discipline would have been faster.",
                    "Stop tapping. The app is not worth this."
                ],
                milestones: [
                    "100 taps. And you still want the app?",
                    "200 taps. The scroll better be worth it.",
                    "300 taps. Your thumb has more discipline than you.",
                    "400 taps. This is getting embarrassing.",
                    "500 taps. You can still stop digging.",
                    "600 taps. Imagine putting this effort into your goals.",
                    "700 taps. The phone really has you trained.",
                    "800 taps. Still choosing the screen?",
                    "900 taps. Put the phone down before it wins again."
                ]
            )
        case .rager:
            return PrisonMessageSet(
                progress: [
                    "STOP RIGHT NOW!! PUT THE PHONE DOWN!",
                    "YOU HIT YOUR LIMIT AND RAN STRAIGHT BACK!",
                    "PHONE ADDICTION IS REAL. THIS IS WHAT IT LOOKS LIKE!",
                    "THE FEED DOES NOT CARE ABOUT YOUR LIFE!",
                    "YOU MADE THE RULE! STOP TRYING TO ESCAPE IT!",
                    "YOUR SCREEN IS NOT MORE IMPORTANT THAN YOUR GOALS!",
                    "QUIT BEGGING AN APP FOR ANOTHER DOPAMINE HIT!",
                    "YOU ARE LOSING TIME YOU WILL NEVER GET BACK!",
                    "THIS IS PATHETIC. PROVE YOU CAN WALK AWAY!",
                    "I'M SO PISSED AT YOU! STOP TAPPING AND LEAVE!"
                ],
                milestones: [
                    "100 TAPS! ALL THIS FOR AN APP?!",
                    "200 TAPS! THE PHONE HAS YOU DOING MANUAL LABOR!",
                    "300 TAPS! IMAGINE WORKING THIS HARD ON YOUR ACTUAL LIFE!",
                    "400 TAPS! THIS IS EMBARRASSING! STOP!",
                    "500 TAPS! HALF A THOUSAND TAPS FOR MORE SCREEN TIME!",
                    "600 TAPS! YOUR THUMB IS WORKING HARDER THAN YOUR DISCIPLINE!",
                    "700 TAPS! THE ALGORITHM HAS YOU COMPLETELY TRAINED!",
                    "800 TAPS! PUT THIS ENERGY INTO LITERALLY ANYTHING ELSE!",
                    "900 TAPS! STOP FEEDING THE HABIT AND PUT THE PHONE DOWN!"
                ]
            )
        }
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
