import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import UserNotifications

@MainActor
final class JailController: ObservableObject {
    @Published var selection = FamilyActivitySelection()
    @Published var isLockActive = false
    @Published var authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    @Published var errorMessage: String?
    @Published var dailyBudgetMinutes = 60
    @Published var isBudgetMonitoring = false
    @Published var hasSeenOnboarding = false
    @Published private(set) var budgetStartedAt: Date?

    @Published private(set) var tapTarget = 100

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let store = ManagedSettingsStore()
    private let activityCenter = DeviceActivityCenter()
    private let defaults = UserDefaults(suiteName: TapJailConstants.appGroupID)

    init() {
#if DEBUG
        if let debugTarget = ProcessInfo.processInfo.environment["TAPJAIL_TAP_TARGET"]
            .flatMap(Int.init),
           debugTarget > 0 {
            tapTarget = debugTarget
            loadState()
            migrateOnboardingGraceDayIfNeeded()
            syncReportConfigurationIfNeeded()
            return
        }
#endif

        let savedTarget = defaults?.integer(forKey: TapJailConstants.StorageKey.tapTarget) ?? 0
        tapTarget = savedTarget > 0 ? savedTarget : 100
        defaults?.set(tapTarget, forKey: TapJailConstants.StorageKey.tapTarget)
        loadState()
        migrateOnboardingGraceDayIfNeeded()
        syncReportConfigurationIfNeeded()
    }

    var hasSelection: Bool {
        !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty || !selection.webDomainTokens.isEmpty
    }

    var selectionSummary: String {
        let appCount = selection.applicationTokens.count
        let categoryCount = selection.categoryTokens.count
        let webCount = selection.webDomainTokens.count

        if appCount + categoryCount + webCount == 0 {
            return "No apps locked. Lock something."
        }

        var parts: [String] = []
        if appCount > 0 { parts.append("\(appCount) app\(appCount == 1 ? "" : "s")") }
        if categoryCount > 0 { parts.append("\(categoryCount) categor\(categoryCount == 1 ? "y" : "ies")") }
        if webCount > 0 { parts.append("\(webCount) web domain\(webCount == 1 ? "" : "s")") }
        return parts.joined(separator: ", ")
    }

    var isOnboardingDay: Bool {
        guard let completedAt = defaults?.object(
            forKey: TapJailConstants.StorageKey.onboardingCompletedAt
        ) as? Date else {
            return false
        }

        return Calendar.current.isDate(completedAt, inSameDayAs: Date())
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            errorMessage = nil
            requestNotificationPermission()
        } catch {
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            errorMessage = error.localizedDescription
        }
    }

    func saveSelection() {
        do {
            let data = try encoder.encode(selection)
            defaults?.set(data, forKey: TapJailConstants.StorageKey.selectedActivitySelection)
            errorMessage = nil
        } catch {
            errorMessage = "Could not save the selected apps."
        }
    }

    func lockNow() {
        saveSelection()
        tapTarget = 100
        defaults?.set(100, forKey: TapJailConstants.StorageKey.tapTarget)
        applyShield(selection: selection)
        defaults?.set(true, forKey: TapJailConstants.StorageKey.isLockActive)
        defaults?.set(Date(), forKey: TapJailConstants.StorageKey.sessionStartedAt)
        isLockActive = true
    }

    func unlock() {
        clearShield()
        defaults?.set(false, forKey: TapJailConstants.StorageKey.isLockActive)
        isLockActive = false
    }

    func completeBreakout() {
        guard isBudgetMonitoring else {
            unlock()
            return
        }

        let extensionMinutes = savedExtensionMinutes
        let currentStage = defaults?.integer(
            forKey: TapJailConstants.StorageKey.breakoutStage
        ) ?? 0
        let nextStage = currentStage + 1
        let nextTapTarget = TapJailConstants.DeviceActivity.tapsRequired(for: nextStage)

        if hasTimeForFullExtension(minutes: extensionMinutes) {
            if scheduleExtension(stage: nextStage, minutes: extensionMinutes) {
                unlock()
                defaults?.set(
                    false,
                    forKey: TapJailConstants.StorageKey.budgetThresholdReached
                )
                sendExtensionGrantedNotification(
                    extensionMinutes: extensionMinutes,
                    nextTapTarget: nextTapTarget
                )
            }
        } else {
            unlock()
            defaults?.set(false, forKey: TapJailConstants.StorageKey.budgetThresholdReached)
            activityCenter.stopMonitoring([TapJailConstants.DeviceActivity.extensionBudget])
            sendUnlockedUntilMidnightNotification()
        }
    }

    func startDailyBudget(minutes overrideMinutes: Int? = nil) {
        guard hasSelection else {
            errorMessage = "Choose at least one app or category first."
            return
        }

        let isDebugTest = overrideMinutes == 1
        let thresholdMinutes = isDebugTest
            ? 1
            : TapJailConstants.DeviceActivity.normalizedBudgetMinutes(dailyBudgetMinutes)
        let extensionMinutes = isDebugTest
            ? 1
            : TapJailConstants.DeviceActivity.extensionMinutes
        saveSelection()

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )
        let usesOnboardingGrace = isOnboardingDay
        let event = makeEvent(
            minutes: thresholdMinutes,
            includesPastActivity: !usesOnboardingGrace
        )
        let budgetStartedAt = Date()

        do {
            activityCenter.stopMonitoring([
                TapJailConstants.DeviceActivity.dailyBudget,
                TapJailConstants.DeviceActivity.extensionBudget
            ])
            clearShield()
            try activityCenter.startMonitoring(
                TapJailConstants.DeviceActivity.dailyBudget,
                during: schedule,
                events: [TapJailConstants.DeviceActivity.event(for: 0): event]
            )
            if !isDebugTest {
                dailyBudgetMinutes = thresholdMinutes
                defaults?.set(
                    thresholdMinutes,
                    forKey: TapJailConstants.StorageKey.dailyBudgetMinutes
                )
            }
            defaults?.set(
                thresholdMinutes,
                forKey: TapJailConstants.StorageKey.activeBudgetMinutes
            )
            defaults?.set(
                budgetStartedAt,
                forKey: TapJailConstants.StorageKey.budgetStartedAt
            )
            writeReportConfiguration(
                budgetMinutes: thresholdMinutes,
                startedAt: budgetStartedAt
            )
            self.budgetStartedAt = budgetStartedAt
            defaults?.set(true, forKey: TapJailConstants.StorageKey.isBudgetMonitoring)
            defaults?.set(false, forKey: TapJailConstants.StorageKey.isLockActive)
            defaults?.set(false, forKey: TapJailConstants.StorageKey.budgetThresholdReached)
            defaults?.set(
                TapJailConstants.localDayIdentifier(),
                forKey: TapJailConstants.StorageKey.budgetDayIdentifier
            )
            defaults?.set(0, forKey: TapJailConstants.StorageKey.breakoutStage)
            defaults?.set(100, forKey: TapJailConstants.StorageKey.tapTarget)
            defaults?.set(
                extensionMinutes,
                forKey: TapJailConstants.StorageKey.extensionMinutes
            )
            tapTarget = 100
            isLockActive = false
            isBudgetMonitoring = true
            errorMessage = nil
        } catch {
            errorMessage = "Could not start the daily budget: \(error.localizedDescription)"
        }
    }

    func stopDailyBudget() {
        activityCenter.stopMonitoring([
            TapJailConstants.DeviceActivity.dailyBudget,
            TapJailConstants.DeviceActivity.extensionBudget
        ])
        defaults?.set(false, forKey: TapJailConstants.StorageKey.isBudgetMonitoring)
        defaults?.removeObject(forKey: TapJailConstants.StorageKey.activeBudgetMinutes)
        defaults?.removeObject(forKey: TapJailConstants.StorageKey.budgetStartedAt)
        removeReportConfiguration()
        budgetStartedAt = nil
        defaults?.set(false, forKey: TapJailConstants.StorageKey.budgetThresholdReached)
        defaults?.set(
            TapJailConstants.DeviceActivity.extensionMinutes,
            forKey: TapJailConstants.StorageKey.extensionMinutes
        )
        defaults?.set(0, forKey: TapJailConstants.StorageKey.breakoutStage)
        defaults?.set(100, forKey: TapJailConstants.StorageKey.tapTarget)
        tapTarget = 100
        isBudgetMonitoring = false
        unlock()
    }

    func sendPrisonRouteTestNotification() {
        requestNotificationPermission()

        let content = UNMutableNotificationContent()
        content.title = "Tap to enter TapJail"
        content.body = "Tap \(tapTarget) times to break out of TapJail."
        content.sound = .default
        content.userInfo = ["route": "prison"]

        let request = UNNotificationRequest(
            identifier: "tapjail.route-test",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        UNUserNotificationCenter.current().add(request)
    }

    func refreshAuthorizationStatus() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }

    func refreshSharedState() {
        isLockActive = defaults?.bool(forKey: TapJailConstants.StorageKey.isLockActive) ?? false
        let savedTarget = defaults?.integer(forKey: TapJailConstants.StorageKey.tapTarget) ?? 0
        tapTarget = savedTarget > 0 ? savedTarget : 100
        isBudgetMonitoring = defaults?.bool(
            forKey: TapJailConstants.StorageKey.isBudgetMonitoring
        ) ?? false
    }

    func completeOnboarding() {
        let completedAt = Date()
        defaults?.set(true, forKey: TapJailConstants.StorageKey.hasSeenOnboarding)
        defaults?.set(
            completedAt,
            forKey: TapJailConstants.StorageKey.onboardingCompletedAt
        )
        hasSeenOnboarding = true
    }

    private func loadState() {
        if let data = defaults?.data(forKey: TapJailConstants.StorageKey.selectedActivitySelection),
           let savedSelection = try? decoder.decode(FamilyActivitySelection.self, from: data) {
            selection = savedSelection
        }

        isLockActive = defaults?.bool(forKey: TapJailConstants.StorageKey.isLockActive) ?? false
        hasSeenOnboarding = defaults?.bool(forKey: TapJailConstants.StorageKey.hasSeenOnboarding) ?? false
        let savedBudget = defaults?.integer(
            forKey: TapJailConstants.StorageKey.dailyBudgetMinutes
        ) ?? 0
        dailyBudgetMinutes = savedBudget > 0
            ? TapJailConstants.DeviceActivity.normalizedBudgetMinutes(savedBudget)
            : 60
        isBudgetMonitoring = defaults?.bool(
            forKey: TapJailConstants.StorageKey.isBudgetMonitoring
        ) ?? false
        budgetStartedAt = defaults?.object(
            forKey: TapJailConstants.StorageKey.budgetStartedAt
        ) as? Date
    }

    private func migrateOnboardingGraceDayIfNeeded() {
        guard hasSeenOnboarding,
              defaults?.object(
                forKey: TapJailConstants.StorageKey.onboardingCompletedAt
              ) as? Date == nil else {
            return
        }

        let migratedAt = Date()
        defaults?.set(
            migratedAt,
            forKey: TapJailConstants.StorageKey.onboardingCompletedAt
        )

        // Existing development installs get one clean onboarding-day baseline.
        if isBudgetMonitoring, hasSelection {
            startDailyBudget()
        }
    }

    private func syncReportConfigurationIfNeeded() {
        guard isBudgetMonitoring else { return }

        let activeBudget = defaults?.integer(
            forKey: TapJailConstants.StorageKey.activeBudgetMinutes
        ) ?? 0
        let budgetMinutes = activeBudget > 0 ? activeBudget : dailyBudgetMinutes
        let startedAt = budgetStartedAt ?? Date()

        if budgetStartedAt == nil {
            defaults?.set(
                startedAt,
                forKey: TapJailConstants.StorageKey.budgetStartedAt
            )
            budgetStartedAt = startedAt
        }

        writeReportConfiguration(
            budgetMinutes: budgetMinutes,
            startedAt: startedAt
        )
    }

    private func applyShield(selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    private func clearShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }

    private var savedExtensionMinutes: Int {
        let savedMinutes = defaults?.integer(
            forKey: TapJailConstants.StorageKey.extensionMinutes
        ) ?? 0
        return savedMinutes > 0
            ? savedMinutes
            : TapJailConstants.DeviceActivity.extensionMinutes
    }

    @discardableResult
    private func scheduleExtension(stage: Int, minutes: Int) -> Bool {
        let now = Date()
        let calendar = Calendar.current

        let start = calendar.dateComponents([.hour, .minute, .second], from: now)
        let schedule = DeviceActivitySchedule(
            intervalStart: start,
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: false
        )
        let event = makeEvent(
            minutes: minutes,
            includesPastActivity: false
        )

        do {
            activityCenter.stopMonitoring([TapJailConstants.DeviceActivity.extensionBudget])
            try activityCenter.startMonitoring(
                TapJailConstants.DeviceActivity.extensionBudget,
                during: schedule,
                events: [TapJailConstants.DeviceActivity.event(for: stage): event]
            )
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Could not start the next \(minutes)-minute extension: \(error.localizedDescription)"
            return false
        }
    }

    private func makeEvent(minutes: Int, includesPastActivity: Bool) -> DeviceActivityEvent {
        if #available(iOS 17.4, *) {
            return DeviceActivityEvent(
                applications: selection.applicationTokens,
                categories: selection.categoryTokens,
                webDomains: selection.webDomainTokens,
                threshold: DateComponents(minute: minutes),
                includesPastActivity: includesPastActivity
            )
        }

        return DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: minutes)
        )
    }

    private func sendExtensionGrantedNotification(
        extensionMinutes: Int,
        nextTapTarget: Int
    ) {
        let content = UNMutableNotificationContent()
        content.title = "You have \(extensionMinutes) more \(extensionMinutes == 1 ? "minute" : "minutes")"
        content.body = "Next time, tap \(nextTapTarget) times to break out of TapJail."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "tapjail.extension-granted",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func hasTimeForFullExtension(minutes: Int) -> Bool {
        guard let midnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else {
            return false
        }

        return midnight.timeIntervalSinceNow >= Double(minutes * 60)
    }

    private func sendUnlockedUntilMidnightNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Unlocked until midnight"
        content.body = "Your daily budget and tap count reset at midnight."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "tapjail.unlocked-until-midnight",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func writeReportConfiguration(budgetMinutes: Int, startedAt: Date) {
        guard let url = reportConfigurationURL else { return }

        let configuration: [String: Any] = [
            "budgetMinutes": budgetMinutes,
            "startedAt": startedAt
        ]

        guard let data = try? PropertyListSerialization.data(
            fromPropertyList: configuration,
            format: .binary,
            options: 0
        ) else {
            return
        }

        try? data.write(to: url, options: .atomic)
    }

    private func removeReportConfiguration() {
        guard let url = reportConfigurationURL else { return }
        try? FileManager.default.removeItem(at: url)
    }

    private var reportConfigurationURL: URL? {
        FileManager.default
            .containerURL(
                forSecurityApplicationGroupIdentifier: TapJailConstants.appGroupID
            )?
            .appendingPathComponent("TapJailReportConfiguration.plist")
    }
}
