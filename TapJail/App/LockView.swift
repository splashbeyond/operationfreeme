import DeviceActivity
import FamilyControls
import SwiftUI

struct LockView: View {
    @Binding var route: AppRoute
    @EnvironmentObject private var jail: JailController
    @State private var presentedSheet: HomeSheet?
    @State private var isLimitEditorPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    brandHeader
                    budgetHero

                    VStack(spacing: 12) {
                        navigationRow(
                            icon: "slider.horizontal.3",
                            title: "Limit & Apps",
                            detail: budgetAndAppsDetail
                        ) {
                            jail.beginBudgetEditing()
                            isLimitEditorPresented = true
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
            .navigationDestination(isPresented: $isLimitEditorPresented) {
                BudgetEditorView()
            }
            .sheet(item: $presentedSheet) { sheet in
                NavigationStack {
                    switch sheet {
                    case .usage:
                        UsageView()
                    case .settings:
                        SettingsView(route: $route)
                    }
                }
                .presentationDragIndicator(.visible)
                .presentationBackground(TapJailColor.black)
            }
            .onAppear {
                jail.refreshAuthorizationStatus()
                jail.refreshSharedState()
            }
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
                Label("TODAY'S APP LIMIT", systemImage: "hourglass")
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
                    isLimitEditorPresented = true
                } label: {
                    Text(jail.hasSelection ? "Start Daily App Limit" : "Set Your App Limit")
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
    case usage
    case settings

    var id: String { rawValue }
}

private struct BudgetEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var jail: JailController
    @State private var isChangeConfirmationPresented = false
    @State private var isPickerPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Daily app limit")
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
                    .accessibilityLabel("Daily app limit")
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
                        isPickerPresented = true
                    } label: {
                        Label("Choose Apps", systemImage: "app.badge.checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(TapJailSecondaryButtonStyle())
                }
                .homePanel()

                Button {
                    if jail.isBudgetMonitoring {
                        isChangeConfirmationPresented = true
                    } else if jail.commitBudgetDraft() {
                        dismiss()
                    }
                } label: {
                    Text(updateButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TapJailPrimaryButtonStyle())
                .disabled(
                    !hasScreenTimeAuthorization
                        || !jail.hasDraftSelection
                        || (!jail.bonusBudgetChangeAvailable
                            && !jail.canScheduleBudgetChangeToday
                            && jail.isBudgetMonitoring)
                )

                if jail.isBudgetMonitoring {
                    Text(changeRuleText)
                        .font(.tapJail(13, weight: .light))
                        .foregroundStyle(TapJailColor.muted)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

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
        .navigationTitle("Limit & Apps")
        .navigationBarTitleDisplayMode(.inline)
        .familyActivityPicker(
            headerText: "Choose what TapJail blocks.",
            footerText: "These selections stay on this device.",
            isPresented: $isPickerPresented,
            selection: $jail.selectionDraft
        )
        .confirmationDialog(
            confirmationTitle,
            isPresented: $isChangeConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(confirmButtonTitle) {
                if jail.commitBudgetDraft() {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(confirmationMessage)
        }
    }

    private var budgetRange: ClosedRange<Double> {
        let minimum = Double(TapJailConstants.DeviceActivity.minimumBudgetMinutes)
        let maximum = Double(TapJailConstants.DeviceActivity.maximumBudgetMinutes)
        return minimum...maximum
    }

    private var updateButtonTitle: String {
        if !jail.isBudgetMonitoring {
            return "Set Daily App Limit"
        }
        return jail.bonusBudgetChangeAvailable
            ? "Update Limit"
            : "Set Tomorrow's Limit"
    }

    private var changeRuleText: String {
        if jail.bonusBudgetChangeAvailable {
            return "This is your one extra change after setup."
        }
        if jail.canScheduleBudgetChangeToday {
            return "You can change your limit once per day. This change starts tomorrow."
        }
        return "You already used today's change."
    }

    private var confirmationTitle: String {
        jail.bonusBudgetChangeAvailable
            ? "Update today's limit?"
            : "Set tomorrow's limit?"
    }

    private var confirmationMessage: String {
        if jail.bonusBudgetChangeAvailable {
            return "You get one extra change after setup. After this, today's limit cannot be changed again."
        }
        return "You can change your limit once per day. This new limit will start at midnight."
    }

    private var confirmButtonTitle: String {
        jail.bonusBudgetChangeAvailable
            ? "Update Today's Limit"
            : "Set Tomorrow's Limit"
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

    private var todayInterval: DateInterval {
        Calendar.current.dateInterval(of: .day, for: Date()) ?? DateInterval()
    }

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

                // Live screen time report from DeviceActivity
                if jail.isBudgetMonitoring {
                    DeviceActivityReport(
                        .init("tapjail.budget"),
                        filter: DeviceActivityFilter(
                            segment: .daily(during: todayInterval),
                            users: .all,
                            devices: .init([.iPhone])
                        )
                    )
                    .frame(minHeight: 100)
                    .padding(20)
                    .background(TapJailColor.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(TapJailColor.divider, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                VStack(spacing: 0) {
                    usageStat(title: "Daily budget", value: durationText(jail.dailyBudgetMinutes))
                    Divider().overlay(TapJailColor.divider)
                    usageStat(title: "Selected", value: compactSelectionSummary)
                    Divider().overlay(TapJailColor.divider)
                    usageStat(title: "Next breakout", value: "\(jail.tapTarget) taps")
                }
                .homePanel()
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
            return "iOS is watching your selected apps for today's limit."
        }
        return "Set a daily app limit to begin."
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
