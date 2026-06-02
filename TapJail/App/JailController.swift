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

    let tapTarget: Int

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let store = ManagedSettingsStore()
    private let defaults = UserDefaults(suiteName: TapJailConstants.appGroupID)

    init() {
        let savedTarget = defaults?.integer(forKey: TapJailConstants.StorageKey.tapTarget) ?? 0
        tapTarget = savedTarget > 0 ? savedTarget : 100
        defaults?.set(tapTarget, forKey: TapJailConstants.StorageKey.tapTarget)
        loadState()
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

    func sendPrisonRouteTestNotification() {
        requestNotificationPermission()

        let content = UNMutableNotificationContent()
        content.title = "Tap to enter TapJail"
        content.body = "Pay the toll to break out."
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

    private func loadState() {
        if let data = defaults?.data(forKey: TapJailConstants.StorageKey.selectedActivitySelection),
           let savedSelection = try? decoder.decode(FamilyActivitySelection.self, from: data) {
            selection = savedSelection
        }

        isLockActive = defaults?.bool(forKey: TapJailConstants.StorageKey.isLockActive) ?? false
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

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}
