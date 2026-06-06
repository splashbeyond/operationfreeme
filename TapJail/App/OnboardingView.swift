import StoreKit
import SwiftUI

struct OnboardingView: View {
    @Binding var route: AppRoute
    @EnvironmentObject private var jail: JailController

    @State private var step = 0

    // Quiz
    @State private var selectedGoal: String? = nil
    @State private var selectedPain: String? = nil

    // Screen time slider
    @State private var screenTimeHours: Double = 3

    // Demo circle (step 2)
    @State private var demoTapCount = 0

    // Analyzing (step 8)
    @State private var analysisProgress: Double = 0

    // Life dots (step 12)
    @State private var dotsRevealed = 0

    // Commitment circle (step 16)
    @State private var commitTapCount = 0
    @State private var committed = false

    // Time savings animation (step 14)
    @State private var tsDotRevealCount = 0
    @State private var tsPhoneYearsReduced = false

    // Star review (step 17)
    @State private var starRating = 0

    // Auth error
    @State private var showAuthError = false

    private let totalSteps = 21

    private let sleepYears = 27
    private let workYears = 13

    private var isAuthorized: Bool {
        switch jail.authorizationStatus {
        case .approved, .approvedWithDataAccess:
            return true
        default:
            return false
        }
    }

    // MARK: - Derived

    private var yearsLost: Int {
        max(1, Int(screenTimeHours * 80.0 / 16.0))
    }

    private var yearsRecovered: Int {
        max(1, yearsLost / 2)
    }

    private var profileName: String {
        switch screenTimeHours {
        case ..<2:   return "The Casual Checker"
        case ..<4:   return "The Habitual Scroller"
        case ..<6:   return "The Daily Drainer"
        case ..<8:   return "The Deep Scroller"
        default:     return "The All-Day Addict"
        }
    }

    private var profileDescription: String {
        switch screenTimeHours {
        case ..<2:
            return "You check your phone often but keep sessions short. TapJail helps you make those checks intentional."
        case ..<4:
            return "You're in the average range — but averages still add up to years of your life. TapJail makes every session a choice."
        case ..<6:
            return "Your phone is taking a significant portion of your day. Most of that time probably wasn't planned."
        case ..<8:
            return "Your screen time is eating into sleep, work, and relationships. TapJail puts friction between you and the habit."
        default:
            return "Your phone is your default state. That is the problem TapJail is built to solve."
        }
    }

    // MARK: - Navigation

    private func advance() {
        withAnimation(.easeInOut(duration: 0.32)) { step += 1 }
    }

    private var pageTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            TapJailColor.black.ignoresSafeArea()

            if step < totalSteps {
                progressBar
            }

            ZStack {
                switch step {
                case 0:  welcomeScreen
                case 1:  mechanicScreen
                case 2:  demoScreen
                case 3:  notYourFaultScreen
                case 4:  personalizeScreen
                case 5:  goalScreen
                case 6:  painScreen
                case 7:  screenTimeScreen
                case 8:  analyzingScreen
                case 9:  profileScreen
                case 10: oofScreen
                case 11: yearsLostScreen
                case 12: lifeDotsScreen
                case 13: goodNewsScreen
                case 14: timeSavingsScreen
                case 15: whyItWorksScreen
                case 16: researchScreen
                case 17: reviewScreen
                case 18: commitmentScreen
                case 19: permissionScreen
                case 20: beforeAfterScreen
                default: paywallScreen
                }
            }
            .id(step)
            .transition(pageTransition)
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(TapJailColor.white.opacity(0.1))
                Capsule()
                    .fill(TapJailColor.red)
                    .frame(width: geo.size.width * (Double(min(step, totalSteps - 1)) / Double(totalSteps - 1)))
                    .animation(.easeInOut(duration: 0.3), value: step)
            }
            .frame(height: 3)
        }
        .frame(height: 3)
        .padding(.horizontal, 24)
        .padding(.top, 56)
    }

    // MARK: - Step 0: Welcome

    private var welcomeScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("TapJailIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

            Spacer().frame(height: 32)

            Text("TapJail")
                .font(.tapJail(52, weight: .bold))
                .foregroundStyle(TapJailColor.white)

            Spacer().frame(height: 16)

            Text("Your phone is winning.\nTapJail fixes that.")
                .font(.tapJail(20))
                .foregroundStyle(TapJailColor.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()

            primaryButton("Lock In") { advance() }
                .padding(.horizontal, 24)

            Spacer().frame(height: 50)
        }
    }

    // MARK: - Step 1: The Mechanic

    private var mechanicScreen: some View {
        scrollScreen {
            Spacer().frame(height: 24)

            Text("How it works.")
                .font(.tapJail(32, weight: .bold))
                .foregroundStyle(TapJailColor.white)

            Spacer().frame(height: 32)

            VStack(spacing: 12) {
                mechanicRow(number: "1", icon: "square.grid.2x2.fill", text: "Pick the apps that waste your time.")
                mechanicRow(number: "2", icon: "lock.fill", text: "Start the lock.")
                mechanicRow(number: "3", icon: "shield.fill", text: "Open a blocked app — TapJail stops you.")
                mechanicRow(number: "4", icon: "hand.tap.fill", text: "Tap 100 times to break out.")
            }

            Spacer().frame(height: 12)

            Text("No bypass. No grace period. No shortcuts.")
                .font(.tapJail(14))
                .foregroundStyle(TapJailColor.muted)
                .multilineTextAlignment(.center)

            Spacer()

            primaryButton("Got it") { advance() }
        }
    }

    private func mechanicRow(number: String, icon: String, text: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(TapJailColor.red)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(TapJailColor.white)
            }
            Text(text)
                .font(.tapJail(16))
                .foregroundStyle(TapJailColor.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(16)
        .background(TapJailColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(TapJailColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Step 2: Interactive Demo

    private var demoScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Text("Try it.")
                    .font(.tapJail(32, weight: .bold))
                    .foregroundStyle(TapJailColor.white)
                Text("Tap the circle.")
                    .font(.tapJail(17))
                    .foregroundStyle(TapJailColor.muted)
            }

            Spacer().frame(height: 32)

            Text("\(demoTapCount)")
                .font(.tapJail(80, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .contentTransition(.numericText())
                .frame(height: 88)

            Text("/ 5 taps")
                .font(.tapJail(15))
                .foregroundStyle(TapJailColor.muted)

            Spacer().frame(height: 32)

            Button {
                guard demoTapCount < 5 else { return }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.easeInOut(duration: 0.06)) {
                    demoTapCount += 1
                }
            } label: {
                Circle()
                    .fill(TapJailColor.red)
                    .frame(width: 240, height: 240)
            }
            .buttonStyle(TapCircleButtonStyle())
            .disabled(demoTapCount >= 5)
            .opacity(demoTapCount >= 5 ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.2), value: demoTapCount >= 5)

            Spacer().frame(height: 32)

            if demoTapCount >= 5 {
                primaryButton("That's the mechanic.") { advance() }
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Color.clear.frame(height: 56)
            }

            Spacer().frame(height: 50)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: demoTapCount)
    }

    // MARK: - Step 3: Not Your Fault

    private var notYourFaultScreen: some View {
        scrollScreen {
            Spacer().frame(height: 16)

            VStack(alignment: .leading, spacing: 4) {
                Text("You're not addicted.")
                    .font(.tapJail(28, weight: .bold))
                    .foregroundStyle(TapJailColor.white)
                Text("Your time is being taken.")
                    .font(.tapJail(28, weight: .bold))
                    .foregroundStyle(TapJailColor.red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 28)

            VStack(spacing: 12) {
                infoCard(icon: "iphone", text: "Apps are designed to keep you opening them. You're fighting billion-dollar algorithms.")
                infoCard(icon: "bell.badge.fill", text: "Variable rewards — likes, new posts, notifications — hijack the same brain loops as gambling.")
                infoCard(icon: "hand.tap.fill", text: "TapJail doesn't fight willpower. It makes opening the app cost you something real.")
            }

            Spacer()

            primaryButton("Good to know") { advance() }
        }
    }

    private func infoCard(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(TapJailColor.red)
                .frame(width: 32, height: 32)
                .background(TapJailColor.red.opacity(0.12))
                .clipShape(Circle())
            Text(text)
                .font(.tapJail(15))
                .foregroundStyle(TapJailColor.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(16)
        .background(TapJailColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(TapJailColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func quoteCard(text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "quote.opening")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(TapJailColor.muted)
                .frame(width: 32, height: 32)
                .background(TapJailColor.raised)
                .clipShape(Circle())
            Text(text)
                .font(.tapJail(15))
                .foregroundStyle(TapJailColor.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(16)
        .background(TapJailColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(TapJailColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Step 4: Personalize

    private var personalizeScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("TapJailIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) { }
                }

            Spacer().frame(height: 28)

            Text("Let's set up TapJail for you.")
                .font(.tapJail(28, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 12)

            Text("Your answers shape how TapJail locks in.")
                .font(.tapJail(16))
                .foregroundStyle(TapJailColor.muted)
                .multilineTextAlignment(.center)

            Spacer()

            primaryButton("Let's do it") { advance() }
                .padding(.horizontal, 24)

            Spacer().frame(height: 50)
        }
    }

    // MARK: - Step 5: Goal Quiz

    private let goals = [
        "Get more focused",
        "Stop mindless scrolling",
        "Sleep better",
        "Be more productive",
        "Spend less time on my phone",
        "Just trying it out",
    ]

    private var goalScreen: some View {
        quizScreen(
            question: "What's your main goal?",
            options: goals,
            selected: $selectedGoal
        ) { advance() }
    }

    // MARK: - Step 6: Pain Quiz

    private let pains = [
        "Loss of focus",
        "Anxiety or overstimulation",
        "Bad sleep",
        "Productivity drops",
        "I feel mentally drained",
        "Less time with people I care about",
    ]

    private var painScreen: some View {
        quizScreen(
            question: "How does your phone affect you most?",
            options: pains,
            selected: $selectedPain
        ) { advance() }
    }

    private func quizScreen(
        question: String,
        options: [String],
        selected: Binding<String?>,
        onContinue: @escaping () -> Void
    ) -> some View {
        scrollScreen {
            Spacer().frame(height: 16)

            Text(question)
                .font(.tapJail(26, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 28)

            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.65)) {
                            selected.wrappedValue = option
                        }
                    } label: {
                        HStack {
                            Text(option)
                                .font(.tapJail(16))
                                .foregroundStyle(TapJailColor.white)
                            Spacer()
                            if selected.wrappedValue == option {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(TapJailColor.red)
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 56)
                        .background(
                            selected.wrappedValue == option
                                ? TapJailColor.red.opacity(0.12)
                                : TapJailColor.surface
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    selected.wrappedValue == option
                                        ? TapJailColor.red
                                        : TapJailColor.divider,
                                    lineWidth: selected.wrappedValue == option ? 1.5 : 1
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .scaleEffect(selected.wrappedValue == option ? 1.01 : 1)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            primaryButton("Continue", disabled: selected.wrappedValue == nil) { onContinue() }
        }
    }

    // MARK: - Step 7: Screen Time Slider

    private var screenTimeScreen: some View {
        scrollScreen {
            Spacer().frame(height: 16)

            Text("How long are you on your phone each day?")
                .font(.tapJail(26, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("You can tell the truth.")
                .font(.tapJail(14))
                .foregroundStyle(TapJailColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 32)

            Text("\(Int(screenTimeHours)) hrs")
                .font(.tapJail(56, weight: .bold))
                .foregroundStyle(TapJailColor.red)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.1), value: Int(screenTimeHours))

            Spacer().frame(height: 20)

            Slider(value: $screenTimeHours, in: 0...12, step: 0.5)
                .tint(TapJailColor.red)
                .padding(.horizontal, 4)
                .onChange(of: screenTimeHours) { _, _ in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }

            HStack {
                Text("0h").font(.tapJail(12)).foregroundStyle(TapJailColor.muted)
                Spacer()
                Text("12h+").font(.tapJail(12)).foregroundStyle(TapJailColor.muted)
            }

            Spacer().frame(height: 12)

            Text(screenTimeLabel)
                .font(.tapJail(14))
                .foregroundStyle(TapJailColor.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.easeInOut(duration: 0.15), value: screenTimeLabel)

            Spacer()

            primaryButton("Continue") { advance() }
        }
    }

    private var screenTimeLabel: String {
        switch screenTimeHours {
        case ..<1:   return "Good starting point."
        case ..<2:   return "Below average."
        case ..<4:   return "The average person's range."
        case ..<6:   return "That's a significant chunk of your day."
        case ..<8:   return "That's a significant percentage of your life."
        case ..<10:  return "More than a part-time job."
        default:     return "Almost your entire waking life."
        }
    }

    // MARK: - Step 8: Analyzing

    private var analyzingScreen: some View {
        VStack {
            Spacer()
            VStack(spacing: 10) {
                Text("Analyzing your habits...")
                    .font(.tapJail(16))
                    .foregroundStyle(TapJailColor.muted)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(TapJailColor.white.opacity(0.1))
                        Capsule()
                            .fill(TapJailColor.red)
                            .frame(width: geo.size.width * analysisProgress)
                            .animation(.easeInOut(duration: 2.5), value: analysisProgress)
                    }
                    .frame(height: 3)
                }
                .frame(height: 3)
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 50)
        }
        .task {
            analysisProgress = 1.0
            try? await Task.sleep(nanoseconds: 2_700_000_000)
            advance()
        }
    }

    // MARK: - Step 9: Profile Reveal

    private var profileScreen: some View {
        scrollScreen {
            Spacer().frame(height: 24)

            Text("Your profile is")
                .font(.tapJail(16))
                .foregroundStyle(TapJailColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(profileName)
                .font(.tapJail(32, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 20)

            Text(profileDescription)
                .font(.tapJail(16))
                .foregroundStyle(TapJailColor.muted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 24)

            VStack(spacing: 14) {
                metricBar(label: "Phone dependency", fill: min(1.0, screenTimeHours / 12.0))
                metricBar(label: "Daily time lost", fill: min(1.0, screenTimeHours / 10.0))
            }

            Spacer()

            primaryButton("Makes sense") { advance() }
        }
    }

    private func metricBar(label: String, fill: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.tapJail(13))
                .foregroundStyle(TapJailColor.muted)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(TapJailColor.raised)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(TapJailColor.red)
                        .frame(width: geo.size.width * fill)
                }
                .frame(height: 8)
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(TapJailColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(TapJailColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Step 10: OOF

    private var oofScreen: some View {
        ZStack {
            TapJailColor.black.ignoresSafeArea()

            VStack {
                Spacer()
                Text("OOF")
                    .font(.tapJail(96, weight: .bold))
                    .foregroundStyle(TapJailColor.white)
                Spacer().frame(height: 16)
                Text("I have some bad news for you...")
                    .font(.tapJail(18))
                    .foregroundStyle(TapJailColor.muted)
                Spacer()
                Button("Skip") { advance() }
                    .font(.tapJail(15))
                    .foregroundStyle(TapJailColor.muted)
                Spacer().frame(height: 48)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { advance() }
        .onAppear {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }

    // MARK: - Step 11: Years Lost

    private var yearsLostScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("You're on track to spend")
                .font(.tapJail(18))
                .foregroundStyle(TapJailColor.muted)

            Spacer().frame(height: 12)

            Text("\(yearsLost) years")
                .font(.tapJail(72, weight: .bold))
                .foregroundStyle(TapJailColor.red)

            Spacer().frame(height: 8)

            Text("of your life on this phone")
                .font(.tapJail(18))
                .foregroundStyle(TapJailColor.muted)

            Spacer().frame(height: 20)

            Text("Projection based on your answers.")
                .font(.tapJail(12))
                .foregroundStyle(TapJailColor.muted.opacity(0.6))

            Spacer()

            primaryButton("Next") { advance() }
                .padding(.horizontal, 24)

            Spacer().frame(height: 50)
        }
        .multilineTextAlignment(.center)
        .onAppear {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }

    // MARK: - Step 12: Life Dots

    private var freeYears: Int {
        max(0, 80 - sleepYears - workYears - yearsLost)
    }

    private var lifeDotsScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Your life,\nbroken down.")
                .font(.tapJail(26, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 28)

            LifeDotsGrid(yearsLost: yearsLost, sleepYears: sleepYears, workYears: workYears, revealed: dotsRevealed)

            Spacer().frame(height: 20)

            VStack(spacing: 8) {
                HStack(spacing: 20) {
                    legendDot(color: TapJailColor.raised, label: "\(freeYears) yrs free time")
                    legendDot(color: TapJailColor.red, label: "\(yearsLost) yrs on your phone")
                }
                HStack(spacing: 20) {
                    legendDot(color: TapJailColor.blue, label: "\(sleepYears) yrs asleep")
                    legendDot(color: TapJailColor.green, label: "\(workYears) yrs working")
                }
            }

            Spacer()

            primaryButton("Next") { advance() }
                .padding(.horizontal, 24)

            Spacer().frame(height: 50)
        }
        .task {
            for i in 0...80 {
                try? await Task.sleep(nanoseconds: 20_000_000)
                dotsRevealed = i
            }
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label).font(.tapJail(12)).foregroundStyle(TapJailColor.muted)
        }
    }

    // MARK: - Step 13: Good News

    private var goodNewsScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("TapJailIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Spacer().frame(height: 28)

            Text("The good news is...")
                .font(.tapJail(18))
                .foregroundStyle(TapJailColor.muted)

            Spacer().frame(height: 8)

            Text("TapJail can help you reclaim")
                .font(.tapJail(22, weight: .bold))
                .foregroundStyle(TapJailColor.white)

            Text("\(yearsRecovered) years")
                .font(.tapJail(64, weight: .bold))
                .foregroundStyle(TapJailColor.green)

            Text("back.")
                .font(.tapJail(22, weight: .bold))
                .foregroundStyle(TapJailColor.white)

            Spacer()

            primaryButton("Let's do this") { advance() }
                .padding(.horizontal, 24)

            Spacer().frame(height: 50)
        }
        .multilineTextAlignment(.center)
        .onAppear {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // MARK: - Step 14: Time Savings

    private var reducedYearsLost: Int {
        max(0, yearsLost - yearsRecovered)
    }

    private var timeSavingsScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Here's what that looks like.")
                .font(.tapJail(26, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 28)

            LifeDotsGrid(
                yearsLost: tsPhoneYearsReduced ? reducedYearsLost : yearsLost,
                sleepYears: sleepYears,
                workYears: workYears,
                revealed: tsDotRevealCount
            )

            Spacer().frame(height: 20)

            VStack(spacing: 8) {
                HStack(spacing: 20) {
                    legendDot(color: TapJailColor.raised, label: "\(freeYears) yrs free time")
                    legendDot(color: TapJailColor.red, label: "phone")
                }
                HStack(spacing: 20) {
                    legendDot(color: TapJailColor.blue, label: "\(sleepYears) yrs asleep")
                    legendDot(color: TapJailColor.green, label: "\(workYears) yrs working")
                }
            }

            Spacer().frame(height: 32)

            if tsPhoneYearsReduced {
                VStack(spacing: 6) {
                    Text("\(yearsRecovered) years")
                        .font(.tapJail(48, weight: .bold))
                        .foregroundStyle(TapJailColor.green)
                    Text("back in your life.")
                        .font(.tapJail(18))
                        .foregroundStyle(TapJailColor.muted)
                }
                .multilineTextAlignment(.center)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Color.clear.frame(height: 80)
            }

            Spacer()

            primaryButton("Continue") { advance() }
                .padding(.horizontal, 24)

            Spacer().frame(height: 50)
        }
        .animation(.easeInOut(duration: 0.4), value: tsPhoneYearsReduced)
        .task {
            for i in 0...80 {
                try? await Task.sleep(nanoseconds: 18_000_000)
                tsDotRevealCount = i
            }
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation(.easeInOut(duration: 0.3)) {
                tsPhoneYearsReduced = true
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // MARK: - Step 15: Why It Works

    private var whyItWorksScreen: some View {
        scrollScreen {
            Spacer().frame(height: 16)

            Text("Why TapJail works.")
                .font(.tapJail(28, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 28)

            VStack(spacing: 10) {
                comparisonCard(icon: "xmark", label: "App blockers → You bypass them and feel worse.", positive: false)
                comparisonCard(icon: "xmark", label: "Timers → Easy to ignore. No real cost.", positive: false)
                comparisonCard(icon: "checkmark", label: "TapJail → Opens the app costs 100 taps. A real, physical price.", positive: true)
            }

            Spacer().frame(height: 16)

            Text("Most people decide the app isn't worth 100 taps. That's the whole idea.")
                .font(.tapJail(14))
                .foregroundStyle(TapJailColor.muted)
                .multilineTextAlignment(.center)

            Spacer()

            primaryButton("Continue") { advance() }
        }
    }

    private func comparisonCard(icon: String, label: String, positive: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(positive ? TapJailColor.green : TapJailColor.red)
                .frame(width: 28, height: 28)
                .background(positive ? TapJailColor.green.opacity(0.12) : TapJailColor.red.opacity(0.12))
                .clipShape(Circle())

            Text(label)
                .font(.tapJail(15))
                .foregroundStyle(TapJailColor.white)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(16)
        .background(TapJailColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(positive ? TapJailColor.green.opacity(0.3) : TapJailColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Step 16: Research

    private var researchScreen: some View {
        scrollScreen {
            Spacer().frame(height: 16)

            Text("What your phone\nis doing to you.")
                .font(.tapJail(28, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Backed by research.")
                .font(.tapJail(14))
                .foregroundStyle(TapJailColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 24)

            VStack(spacing: 12) {
                researchCard(
                    icon: "brain.head.profile",
                    stat: "23 minutes",
                    detail: "to refocus after one phone notification. Most people get 50+ per day."
                )
                researchCard(
                    icon: "chart.line.downtrend.xyaxis",
                    stat: "40% less",
                    detail: "work gets done when you keep switching between your phone and a task."
                )
                researchCard(
                    icon: "moon.zzz",
                    stat: "1–2 hours",
                    detail: "of sleep lost per night for heavy phone users. That's 30 days a year."
                )
                researchCard(
                    icon: "heart.slash",
                    stat: "2× more likely",
                    detail: "to report anxiety and depression with 5+ hours of daily screen time."
                )
            }

            Spacer()

            primaryButton("Continue") { advance() }
        }
    }

    private func researchCard(icon: String, stat: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(TapJailColor.red)
                .frame(width: 40, height: 40)
                .background(TapJailColor.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(stat)
                    .font(.tapJail(18, weight: .bold))
                    .foregroundStyle(TapJailColor.white)
                Text(detail)
                    .font(.tapJail(13))
                    .foregroundStyle(TapJailColor.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(TapJailColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(TapJailColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Step 17: Review Request

    private var reviewScreen: some View {
        scrollScreen {
            Spacer().frame(height: 16)

            Text("Enjoying TapJail so far?")
                .font(.tapJail(26, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Your rating helps others find it.")
                .font(.tapJail(15))
                .foregroundStyle(TapJailColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 28)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.6)) {
                            starRating = star
                        }
                        if star >= 4 {
#if !targetEnvironment(simulator)
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                SKStoreReviewController.requestReview(in: scene)
                            }
#endif
                        }
                    } label: {
                        Image(systemName: star <= starRating ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundStyle(star <= starRating ? TapJailColor.red : TapJailColor.muted)
                            .scaleEffect(star <= starRating ? 1.1 : 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer().frame(height: 24)

            quoteCard(text: "My screen time dropped from 6 hours to under 2. The tap requirement made me realize how often I was picking up my phone for no reason.")

            Spacer()

            primaryButton("Continue") { advance() }

            Button("Not now") { advance() }
                .font(.tapJail(15))
                .foregroundStyle(TapJailColor.muted)
                .padding(.top, 4)
        }
    }

    // MARK: - Step 18: Commitment Tap

    private var commitmentScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Text("Ready to lock in?")
                    .font(.tapJail(28, weight: .bold))
                    .foregroundStyle(TapJailColor.white)
                Text("Tap the circle 5 times to commit.")
                    .font(.tapJail(16))
                    .foregroundStyle(TapJailColor.muted)
            }
            .multilineTextAlignment(.center)

            Spacer().frame(height: 32)

            Text("\(commitTapCount)/5")
                .font(.tapJail(22, weight: .bold))
                .foregroundStyle(committed ? TapJailColor.green : TapJailColor.white)
                .contentTransition(.numericText())

            Spacer().frame(height: 24)

            Button {
                guard commitTapCount < 5 else { return }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    commitTapCount += 1
                    if commitTapCount == 5 {
                        committed = true
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                }
            } label: {
                Circle()
                    .fill(committed ? TapJailColor.green : TapJailColor.red)
                    .frame(width: 240, height: 240)
                    .overlay(
                        committed
                            ? AnyView(Image(systemName: "checkmark")
                                .font(.system(size: 56, weight: .bold))
                                .foregroundStyle(TapJailColor.white))
                            : AnyView(EmptyView())
                    )
            }
            .buttonStyle(TapCircleButtonStyle())
            .animation(.easeInOut(duration: 0.3), value: committed)

            Spacer().frame(height: 32)

            if committed {
                primaryButton("I'm locked in") { advance() }
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Color.clear.frame(height: 56)
            }

            Spacer().frame(height: 50)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: committed)
    }

    // MARK: - Step 19: Screen Time Permission

    private var permissionScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(spacing: 20) {
                Image("TapJailIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                Image(systemName: "hourglass")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(TapJailColor.white)
            }

            Spacer().frame(height: 32)

            Text("Connect TapJail to Screen Time")
                .font(.tapJail(26, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 12)

            Text("Your data is completely private and never leaves your device.")
                .font(.tapJail(15))
                .foregroundStyle(TapJailColor.muted)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 8)

            Text("TapJail needs this permission to block apps.")
                .font(.tapJail(14))
                .foregroundStyle(TapJailColor.muted.opacity(0.7))
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                primaryButton("Connect Screen Time") {
                    Task {
                        await jail.requestAuthorization()
                        if isAuthorized {
                            showAuthError = false
                            advance()
                        } else {
                            showAuthError = true
                        }
                    }
                }

                if showAuthError {
                    Text("Screen Time access is needed to block apps. Please try again.")
                        .font(.tapJail(13))
                        .foregroundStyle(TapJailColor.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 50)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Step 20: Before / After

    private var beforeAfterScreen: some View {
        scrollScreen {
            Spacer().frame(height: 16)

            Text("Here's what changes.")
                .font(.tapJail(28, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 28)

            HStack(spacing: 16) {
                beforeAfterColumn(
                    label: "BEFORE",
                    value: "\(Int(screenTimeHours))h avg",
                    labelColor: TapJailColor.red,
                    valueColor: TapJailColor.red
                )
                beforeAfterColumn(
                    label: "WITH TAPJAIL",
                    value: "~\(max(1, Int(screenTimeHours / 2)))h avg",
                    labelColor: TapJailColor.green,
                    valueColor: TapJailColor.green
                )
            }

            Spacer().frame(height: 28)

            VStack(spacing: 10) {
                featureRow(icon: "lock.fill", text: "Blocks the apps that steal your time.")
                featureRow(icon: "arrow.counterclockwise", text: "Resets every night. Fresh start every day.")
                featureRow(icon: "hand.tap.fill", text: "100 taps to break out. Most of the time you won't bother.")
            }

            Spacer()

            primaryButton("I want my time back") { advance() }
        }
    }

    private func beforeAfterColumn(label: String, value: String, labelColor: Color, valueColor: Color) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.tapJail(11, weight: .bold))
                .foregroundStyle(labelColor)
                .tracking(1.2)
            Text(value)
                .font(.tapJail(24, weight: .bold))
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(TapJailColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(labelColor.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(TapJailColor.green)
                .frame(width: 28, height: 28)
                .background(TapJailColor.green.opacity(0.1))
                .clipShape(Circle())

            Text(text)
                .font(.tapJail(15))
                .foregroundStyle(TapJailColor.white)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(14)
        .background(TapJailColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(TapJailColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Step 21: Paywall

    private var paywallScreen: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 80)

                Image("TapJailLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Spacer().frame(height: 24)

                Text("Lock in.\nGet your time back.")
                    .font(.tapJail(32, weight: .bold))
                    .foregroundStyle(TapJailColor.white)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 12)

                HStack(spacing: 12) {
                    badgeLabel("Tap to break out")
                    badgeLabel("Resets nightly")
                }

                Spacer().frame(height: 12)

                Text("No lecturing. No motivational quotes. Just a hard door and a price to open it.")
                    .font(.tapJail(15))
                    .foregroundStyle(TapJailColor.muted)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: 32)

                // MARK: RevenueCat paywall mounts here
                VStack(spacing: 10) {
                    planCard(
                        title: "Yearly",
                        price: "$0.77 / week",
                        detail: "Billed $39.99 / year",
                        highlighted: true
                    )
                    planCard(
                        title: "Weekly",
                        price: "$4.99 / week",
                        detail: "",
                        highlighted: false
                    )
                }
                // MARK: End RevenueCat slot

                Spacer().frame(height: 24)

                primaryButton("Start TapJail") {
                    Task {
                        if !isAuthorized {
                            await jail.requestAuthorization()
                        }
                        jail.completeOnboarding()
                        withAnimation { route = .lock }
                    }
                }
                .padding(.horizontal, 24)

                Button("Skip for now") {
                    jail.completeOnboarding()
                    withAnimation { route = .lock }
                }
                .font(.tapJail(15))
                .foregroundStyle(TapJailColor.muted)
                .padding(.top, 12)

                Spacer().frame(height: 8)

                Text("Cancel anytime · Restore Purchase")
                    .font(.tapJail(11))
                    .foregroundStyle(TapJailColor.muted.opacity(0.5))

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
    }

    private func badgeLabel(_ text: String) -> some View {
        Text(text)
            .font(.tapJail(12, weight: .bold))
            .foregroundStyle(TapJailColor.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(TapJailColor.surface)
            .overlay(
                Capsule().stroke(TapJailColor.divider, lineWidth: 1)
            )
            .clipShape(Capsule())
    }

    private func planCard(title: String, price: String, detail: String, highlighted: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.tapJail(17, weight: .bold))
                    .foregroundStyle(TapJailColor.white)
                if !detail.isEmpty {
                    Text(detail)
                        .font(.tapJail(12))
                        .foregroundStyle(TapJailColor.muted)
                }
            }
            Spacer()
            Text(price)
                .font(.tapJail(17, weight: .bold))
                .foregroundStyle(highlighted ? TapJailColor.green : TapJailColor.muted)
        }
        .padding(18)
        .background(highlighted ? TapJailColor.green.opacity(0.06) : TapJailColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(highlighted ? TapJailColor.green : TapJailColor.divider, lineWidth: highlighted ? 1.5 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Shared Helpers

    private func scrollScreen<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 80)
                content()
                Spacer().frame(height: 50)
            }
            .padding(.horizontal, 24)
        }
    }

    private func primaryButton(
        _ title: String,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(OnboardingPrimaryButtonStyle(disabled: disabled))
        .disabled(disabled)
    }
}

// MARK: - Onboarding Button Style

struct OnboardingPrimaryButtonStyle: ButtonStyle {
    var disabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tapJail(17, weight: .bold))
            .foregroundStyle(disabled ? TapJailColor.muted : TapJailColor.black)
            .padding(.vertical, 16)
            .background(
                disabled
                    ? TapJailColor.raised
                    : TapJailColor.green.opacity(configuration.isPressed ? 0.78 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

// MARK: - Life Dots Grid

struct LifeDotsGrid: View {
    let yearsLost: Int
    let sleepYears: Int
    let workYears: Int
    let revealed: Int

    private let totalDots = 80
    private let columns = 10

    var body: some View {
        let dotSize: CGFloat = 14
        let spacing: CGFloat = 6
        let phoneStart = totalDots - yearsLost
        let workStart = phoneStart - workYears
        let sleepStart = workStart - sleepYears

        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(dotSize), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            ForEach(0..<totalDots, id: \.self) { index in
                let isRevealed = index < revealed
                let color: Color = {
                    if index >= phoneStart { return TapJailColor.red }
                    if index >= workStart  { return TapJailColor.green }
                    if index >= sleepStart { return TapJailColor.blue }
                    return TapJailColor.raised
                }()

                Circle()
                    .fill(isRevealed ? color : Color.clear)
                    .frame(width: dotSize, height: dotSize)
                    .animation(.easeOut(duration: 0.04).delay(Double(index) * 0.015), value: revealed)
                    .animation(.easeInOut(duration: 0.35).delay(Double(totalDots - 1 - index) * 0.02), value: yearsLost)
            }
        }
    }
}
