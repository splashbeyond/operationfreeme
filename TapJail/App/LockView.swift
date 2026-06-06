import FamilyControls
import SwiftUI

struct LockView: View {
    @Binding var route: AppRoute
    @EnvironmentObject private var jail: JailController
    @State private var presentedSheet: HomeSheet?
    @State private var isPickerPresented = false
    @State private var shouldPresentPicker = false
    @State private var shouldReturnToBudgetEditor = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                brandHeader
                budgetHero

                VStack(spacing: 12) {
                    navigationRow(
                        icon: "slider.horizontal.3",
                        title: "Budget & Apps",
                        detail: budgetAndAppsDetail
                    ) {
                        jail.beginBudgetEditing()
                        presentedSheet = .budget
                    }

                    navigationRow(
                        icon: "chart.bar.xaxis",
                        title: "Usage",
                        detail: usageDetail
                    ) {
                        presentedSheet = .usage
                    }

                    navigationRow(
                        icon: "gearshape",
                        title: "Settings",
                        detail: settingsDetail
                    ) {
                        presentedSheet = .settings
                    }
                }

                if let errorMessage = jail.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                        .font(.tapJail(14, weight: .bold))
                        .foregroundStyle(TapJailColor.red)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(TapJailColor.black)
        .sheet(item: $presentedSheet) { sheet in
            NavigationStack {
                switch sheet {
                case .budget:
                    BudgetEditorView {
                        shouldPresentPicker = true
                        shouldReturnToBudgetEditor = true
                        presentedSheet = nil
                    }
                case .usage:
                    UsageView()
                case .settings:
                    SettingsView(route: $route)
                }
            }
            .presentationDragIndicator(.visible)
            .presentationBackground(TapJailColor.black)
        }
        .familyActivityPicker(
            headerText: "Choose what TapJail blocks.",
            footerText: "These selections stay on this device.",
            isPresented: $isPickerPresented,
            selection: $jail.selectionDraft
        )
        .onChange(of: isPickerPresented) { _, isPresented in
            if !isPresented {
                guard shouldReturnToBudgetEditor else { return }
                shouldReturnToBudgetEditor = false
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(300))
                    presentedSheet = .budget
                }
            }
        }
        .onChange(of: presentedSheet) { _, sheet in
            guard sheet == nil, shouldPresentPicker else { return }
            shouldPresentPicker = false
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(350))
                isPickerPresented = true
            }
        }
        .onAppear {
            jail.refreshAuthorizationStatus()
            jail.refreshSharedState()
        }
    }

    private var brandHeader: some View {
        HStack(spacing: 12) {
            Image("TapJailLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .accessibilityHidden(true)

            Text("TapJail")
                .font(.tapJail(30, weight: .bold))
                .foregroundStyle(TapJailColor.white)

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("TapJail")
    }

    private var budgetHero: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                Label("TODAY'S BUDGET", systemImage: "hourglass")
                    .font(.tapJail(12, weight: .bold))
                    .foregroundStyle(TapJailColor.muted)
                    .tracking(1.2)

                Spacer()

                statusPill
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(heroValue)
                    .font(.tapJail(52, weight: .bold))
                    .foregroundStyle(TapJailColor.white)
                    .monospacedDigit()
                    .minimumScaleFactor(0.75)

                Text(heroCaption)
                    .font(.tapJail(16, weight: .light))
                    .foregroundStyle(TapJailColor.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !jail.isBudgetMonitoring {
                Button {
                    jail.beginBudgetEditing()
                    presentedSheet = .budget
                } label: {
                    Text(jail.hasSelection ? "Start Daily Budget" : "Set Your Daily Budget")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TapJailPrimaryButtonStyle())
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [TapJailColor.surface, TapJailColor.row.opacity(0.78)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(TapJailColor.divider.opacity(0.8), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var statusPill: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 7, height: 7)

            Text(statusText)
                .font(.tapJail(12, weight: .bold))
                .foregroundStyle(TapJailColor.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(TapJailColor.raised)
        .clipShape(Capsule())
    }

    private func navigationRow(
        icon: String,
        title: String,
        detail: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(TapJailColor.green)
                    .frame(width: 42, height: 42)
                    .background(TapJailColor.green.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.tapJail(17, weight: .bold))
                        .foregroundStyle(TapJailColor.white)

                    Text(detail)
                        .font(.tapJail(14, weight: .light))
                        .foregroundStyle(TapJailColor.muted)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(TapJailColor.muted)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TapJailColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(TapJailColor.divider.opacity(0.7), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(TapJailRowButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens \(title)")
    }

    private var heroValue: String {
        if jail.isLockActive {
            return "0 min left"
        }
        if jail.isExtensionActive {
            return "\(jail.activeExtensionMinutes) min left"
        }
        return durationText(jail.dailyBudgetMinutes)
    }

    private var heroCaption: String {
        if jail.isLockActive {
            return "Tap \(jail.tapTarget) times to break out"
        }
        if jail.isExtensionActive {
            return "Next time, tap \(jail.nextTapTarget) times to break out"
        }
        if jail.isBudgetMonitoring {
            return "Your selected apps lock when this budget is reached"
        }
        return "Choose a limit for selected apps"
    }

    private var statusText: String {
        if jail.isLockActive { return "LOCKED" }
        return jail.isBudgetMonitoring ? "ACTIVE" : "NOT SET"
    }

    private var statusColor: Color {
        if jail.isLockActive { return TapJailColor.red }
        return jail.isBudgetMonitoring ? TapJailColor.green : TapJailColor.muted
    }

    private var budgetAndAppsDetail: String {
        if let pendingBudgetMinutes = jail.pendingBudgetMinutes {
            return "Today \(durationText(jail.dailyBudgetMinutes)) · Tomorrow \(durationText(pendingBudgetMinutes))"
        }
        return "\(durationText(jail.dailyBudgetMinutes)) · \(jail.selectionSummary)"
    }

    private var usageDetail: String {
        jail.isBudgetMonitoring ? "View today's Screen Time status" : "Start a budget to track today"
    }

    private var settingsDetail: String {
        hasScreenTimeAuthorization ? "Screen Time connected" : "Screen Time access needed"
    }

    private var hasScreenTimeAuthorization: Bool {
        switch jail.authorizationStatus {
        case .approved, .approvedWithDataAccess:
            return true
        default:
            return false
        }
    }
}

private enum HomeSheet: String, Identifiable {
    case budget
    case usage
    case settings

    var id: String { rawValue }
}

private struct BudgetEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var jail: JailController
    let chooseApps: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Daily allowance")
                            .font(.tapJail(17, weight: .bold))
                            .foregroundStyle(TapJailColor.white)

                        Spacer()

                        Text(durationText(jail.budgetDraftMinutes))
                            .font(.tapJail(22, weight: .bold))
                            .foregroundStyle(TapJailColor.green)
                            .monospacedDigit()
                    }

                    Slider(
                        value: Binding(
                            get: { Double(jail.budgetDraftMinutes) },
                            set: { jail.budgetDraftMinutes = Int($0) }
                        ),
                        in: budgetRange,
                        step: Double(TapJailConstants.DeviceActivity.budgetStepMinutes)
                    )
                    .tint(TapJailColor.green)
                    .accessibilityLabel("Daily app budget")
                    .accessibilityValue(durationText(jail.budgetDraftMinutes))

                    HStack {
                        Text("15 min")
                        Spacer()
                        Text("8 hr")
                    }
                    .font(.tapJail(12, weight: .light))
                    .foregroundStyle(TapJailColor.muted)

                    Text(jail.budgetEditorMessage)
                        .font(.tapJail(14, weight: .light))
                        .foregroundStyle(TapJailColor.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .homePanel()

                VStack(alignment: .leading, spacing: 14) {
                    Text("Blocked apps")
                        .font(.tapJail(17, weight: .bold))
                        .foregroundStyle(TapJailColor.white)

                    Text(jail.selectionDraftSummary)
                        .font(.tapJail(14, weight: .light))
                        .foregroundStyle(TapJailColor.muted)

                    Button {
                        chooseApps()
                    } label: {
                        Label("Choose Apps", systemImage: "app.badge.checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(TapJailSecondaryButtonStyle())
                }
                .homePanel()

                Button {
                    if jail.commitBudgetDraft() {
                        dismiss()
                    }
                } label: {
                    Text(updateButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TapJailPrimaryButtonStyle())
                .disabled(!hasScreenTimeAuthorization || !jail.hasDraftSelection)

                if !hasScreenTimeAuthorization {
                    Button {
                        Task { await jail.requestAuthorization() }
                    } label: {
                        Text("Authorize Screen Time")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(TapJailSecondaryButtonStyle())
                }
            }
            .padding(20)
        }
        .background(TapJailColor.black)
        .navigationTitle("Budget & Apps")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundStyle(TapJailColor.green)
            }
        }
    }

    private var budgetRange: ClosedRange<Double> {
        let minimum = Double(TapJailConstants.DeviceActivity.minimumBudgetMinutes)
        let maximum = Double(TapJailConstants.DeviceActivity.maximumBudgetMinutes)
        return minimum...maximum
    }

    private var updateButtonTitle: String {
        if !jail.isBudgetMonitoring {
            return "Start Daily Budget"
        }
        return jail.correctionWindowAvailable
            ? "Use Setup Correction"
            : "Schedule for Midnight"
    }

    private var hasScreenTimeAuthorization: Bool {
        switch jail.authorizationStatus {
        case .approved, .approvedWithDataAccess:
            return true
        default:
            return false
        }
    }
}

private struct UsageView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var jail: JailController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(jail.isLockActive ? "Budget reached" : budgetStatusTitle)
                        .font(.tapJail(34, weight: .bold))
                        .foregroundStyle(TapJailColor.white)

                    Text(usageExplanation)
                        .font(.tapJail(15, weight: .light))
                        .foregroundStyle(TapJailColor.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 0) {
                    usageStat(title: "Daily budget", value: durationText(jail.dailyBudgetMinutes))
                    Divider().overlay(TapJailColor.divider)
                    usageStat(title: "Selected", value: compactSelectionSummary)
                    Divider().overlay(TapJailColor.divider)
                    usageStat(title: "Next breakout", value: "\(jail.tapTarget) taps")
                }
                .homePanel()

                Label(
                    "Exact live usage requires TapJail's Screen Time report extension. This screen currently shows the verified budget status from iOS.",
                    systemImage: "info.circle"
                )
                .font(.tapJail(14, weight: .light))
                .foregroundStyle(TapJailColor.muted)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
        .background(TapJailColor.black)
        .navigationTitle("Usage")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundStyle(TapJailColor.green)
            }
        }
    }

    private func usageStat(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(TapJailColor.muted)
            Spacer()
            Text(value)
                .foregroundStyle(TapJailColor.white)
                .multilineTextAlignment(.trailing)
        }
        .font(.tapJail(16, weight: .regular))
        .padding(.vertical, 15)
    }

    private var budgetStatusTitle: String {
        jail.isBudgetMonitoring ? "Budget active" : "No budget yet"
    }

    private var usageExplanation: String {
        if jail.isLockActive {
            return "Selected apps are shielded until you complete the breakout."
        }
        if jail.isBudgetMonitoring {
            return "iOS is monitoring your selected apps against today's allowance."
        }
        return "Set a daily allowance to begin monitoring selected apps."
    }

    private var compactSelectionSummary: String {
        jail.hasSelection ? jail.selectionSummary : "No apps"
    }
}

private struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var jail: JailController
    @Binding var route: AppRoute

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(spacing: 0) {
                    settingsRow(
                        title: "Screen Time",
                        value: authorizationStatusText,
                        color: hasScreenTimeAuthorization ? TapJailColor.green : TapJailColor.red
                    )
                    Divider().overlay(TapJailColor.divider)
                    settingsRow(
                        title: "Daily reset",
                        value: "Midnight",
                        color: TapJailColor.white
                    )
                }
                .homePanel()

                if !hasScreenTimeAuthorization {
                    Button {
                        Task { await jail.requestAuthorization() }
                    } label: {
                        Text("Authorize Screen Time")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(TapJailPrimaryButtonStyle())
                }

#if DEBUG
                VStack(alignment: .leading, spacing: 12) {
                    Text("Developer Testing")
                        .font(.tapJail(14, weight: .bold))
                        .foregroundStyle(TapJailColor.muted)

                    Button {
                        jail.startDailyBudget(minutes: 1)
                        dismiss()
                    } label: {
                        Text("Start 1-Minute Device Test")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(TapJailSecondaryButtonStyle())
                    .disabled(!hasScreenTimeAuthorization || !jail.hasSelection)

                    Button {
                        jail.lockNow()
                        dismiss()
                    } label: {
                        Text("Lock Now")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(TapJailSecondaryButtonStyle())
                    .disabled(!hasScreenTimeAuthorization || !jail.hasSelection)

                    if jail.isLockActive {
                        Button {
                            route = .prison
                            dismiss()
                        } label: {
                            Text("Enter TapJail")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(TapJailSecondaryButtonStyle())
                    }

                    if jail.isBudgetMonitoring {
                        Button {
                            jail.stopDailyBudget()
                        } label: {
                            Text("Stop Budget Test")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(TapJailDestructiveButtonStyle())
                    }
                }
                .homePanel()
#endif
            }
            .padding(20)
        }
        .background(TapJailColor.black)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundStyle(TapJailColor.green)
            }
        }
    }

    private func settingsRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(TapJailColor.white)
            Spacer()
            Text(value)
                .foregroundStyle(color)
        }
        .font(.tapJail(16, weight: .regular))
        .padding(.vertical, 15)
    }

    private var hasScreenTimeAuthorization: Bool {
        switch jail.authorizationStatus {
        case .approved, .approvedWithDataAccess:
            return true
        default:
            return false
        }
    }

    private var authorizationStatusText: String {
        hasScreenTimeAuthorization ? "Connected" : "Not connected"
    }
}

private extension View {
    func homePanel() -> some View {
        self
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TapJailColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(TapJailColor.divider.opacity(0.7), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private func durationText(_ minutes: Int) -> String {
    let hours = minutes / 60
    let remainingMinutes = minutes % 60

    if hours == 0 {
        return "\(remainingMinutes) min"
    }
    if remainingMinutes == 0 {
        return "\(hours) hr"
    }
    return "\(hours) hr \(remainingMinutes) min"
}

struct TapJailPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tapJail(17, weight: .bold))
            .foregroundStyle(TapJailColor.black)
            .padding(.vertical, 16)
            .background(TapJailColor.green.opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

struct TapJailSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tapJail(17, weight: .bold))
            .foregroundStyle(TapJailColor.white)
            .padding(.vertical, 16)
            .background(TapJailColor.row.opacity(configuration.isPressed ? 0.72 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TapJailColor.divider, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

struct TapJailDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tapJail(17, weight: .bold))
            .foregroundStyle(TapJailColor.red)
            .padding(.vertical, 16)
            .background(TapJailColor.surface.opacity(configuration.isPressed ? 0.72 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TapJailColor.red.opacity(0.65), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

private struct TapJailRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
