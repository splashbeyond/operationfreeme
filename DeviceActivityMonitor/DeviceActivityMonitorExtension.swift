import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import UserNotifications

final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let decoder = JSONDecoder()
    private let store = ManagedSettingsStore()
    private let activityCenter = DeviceActivityCenter()
    private let defaults = UserDefaults(suiteName: TapJailConstants.appGroupID)

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        resetStateIfNeeded()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        clearShield()
        defaults?.set(false, forKey: TapJailConstants.StorageKey.isLockActive)
        defaults?.set(false, forKey: TapJailConstants.StorageKey.budgetThresholdReached)
        defaults?.set(false, forKey: TapJailConstants.StorageKey.isExtensionActive)

        if activity == TapJailConstants.DeviceActivity.activeSessionBudget
            || activity == TapJailConstants.DeviceActivity.dailyBudget {
            promotePendingConfiguration()
            startRepeatingDailyBudget()
        }
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)

        guard let stage = TapJailConstants.DeviceActivity.stage(for: event),
              let selection = loadSelection() else {
            return
        }

        let tapTarget = TapJailConstants.DeviceActivity.tapsRequired(for: stage)
        applyShield(selection: selection)
        defaults?.set(true, forKey: TapJailConstants.StorageKey.isLockActive)
        defaults?.set(true, forKey: TapJailConstants.StorageKey.budgetThresholdReached)
        defaults?.set(Date(), forKey: TapJailConstants.StorageKey.budgetThresholdReachedAt)
        defaults?.set(stage, forKey: TapJailConstants.StorageKey.breakoutStage)
        defaults?.set(false, forKey: TapJailConstants.StorageKey.isExtensionActive)
        defaults?.set(tapTarget, forKey: TapJailConstants.StorageKey.tapTarget)
        TapJailConstants.SharedFile.writeTapTarget(tapTarget)
        sendThresholdNotification(tapTarget: tapTarget)
    }

    private func loadSelection() -> FamilyActivitySelection? {
        guard let data = defaults?.data(
            forKey: TapJailConstants.StorageKey.selectedActivitySelection
        ) else {
            return nil
        }

        return try? decoder.decode(FamilyActivitySelection.self, from: data)
    }

    private func resetStateIfNeeded() {
        let today = TapJailConstants.localDayIdentifier()
        let savedDay = defaults?.string(forKey: TapJailConstants.StorageKey.budgetDayIdentifier)

        guard savedDay != today else { return }

        clearShield()
        defaults?.set(today, forKey: TapJailConstants.StorageKey.budgetDayIdentifier)
        defaults?.set(false, forKey: TapJailConstants.StorageKey.isLockActive)
        defaults?.set(false, forKey: TapJailConstants.StorageKey.budgetThresholdReached)
        defaults?.set(0, forKey: TapJailConstants.StorageKey.breakoutStage)
        defaults?.set(false, forKey: TapJailConstants.StorageKey.isExtensionActive)
        defaults?.set(
            TapJailConstants.DeviceActivity.tapsRequired(for: 0),
            forKey: TapJailConstants.StorageKey.tapTarget
        )
        TapJailConstants.SharedFile.writeTapTarget(
            TapJailConstants.DeviceActivity.tapsRequired(for: 0)
        )
    }

    private func sendThresholdNotification(tapTarget: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Your apps are locked"
        content.body = "Tap \(tapTarget) times to break out of TapJail."
        content.sound = .default
        content.userInfo = ["route": "prison"]

        let request = UNNotificationRequest(
            identifier: "tapjail.threshold.\(tapTarget)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func applyShield(selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty
            ? nil
            : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty
            ? nil
            : selection.webDomainTokens
    }

    private func clearShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }

    private func startRepeatingDailyBudget() {
        guard defaults?.bool(
            forKey: TapJailConstants.StorageKey.isBudgetMonitoring
        ) == true,
        let selection = loadSelection() else {
            return
        }

        let savedMinutes = defaults?.integer(
            forKey: TapJailConstants.StorageKey.activeBudgetMinutes
        ) ?? 0
        let budgetMinutes = savedMinutes > 0 ? savedMinutes : 60
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )
        let event: DeviceActivityEvent

        if #available(iOS 17.4, *) {
            event = DeviceActivityEvent(
                applications: selection.applicationTokens,
                categories: selection.categoryTokens,
                webDomains: selection.webDomainTokens,
                threshold: DateComponents(minute: budgetMinutes),
                includesPastActivity: false
            )
        } else {
            event = DeviceActivityEvent(
                applications: selection.applicationTokens,
                categories: selection.categoryTokens,
                webDomains: selection.webDomainTokens,
                threshold: DateComponents(minute: budgetMinutes)
            )
        }

        do {
            activityCenter.stopMonitoring([
                TapJailConstants.DeviceActivity.dailyBudget
            ])
            try activityCenter.startMonitoring(
                TapJailConstants.DeviceActivity.dailyBudget,
                during: schedule,
                events: [TapJailConstants.DeviceActivity.event(for: 0): event]
            )
        } catch {
            defaults?.set(false, forKey: TapJailConstants.StorageKey.isBudgetMonitoring)
        }
    }

    private func promotePendingConfiguration() {
        let pendingMinutes = defaults?.integer(
            forKey: TapJailConstants.StorageKey.pendingBudgetMinutes
        ) ?? 0
        if pendingMinutes > 0 {
            defaults?.set(
                pendingMinutes,
                forKey: TapJailConstants.StorageKey.dailyBudgetMinutes
            )
            defaults?.set(
                pendingMinutes,
                forKey: TapJailConstants.StorageKey.activeBudgetMinutes
            )
        }

        if let pendingSelection = defaults?.data(
            forKey: TapJailConstants.StorageKey.pendingActivitySelection
        ) {
            defaults?.set(
                pendingSelection,
                forKey: TapJailConstants.StorageKey.selectedActivitySelection
            )
        }

        defaults?.removeObject(forKey: TapJailConstants.StorageKey.pendingBudgetMinutes)
        defaults?.removeObject(forKey: TapJailConstants.StorageKey.pendingActivitySelection)
        defaults?.removeObject(forKey: TapJailConstants.StorageKey.budgetCommittedAt)
        defaults?.removeObject(forKey: TapJailConstants.StorageKey.correctionUsedDayIdentifier)
    }
}
