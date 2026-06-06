import ManagedSettings
import UserNotifications

final class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handle(action: action, completionHandler: completionHandler)
    }

    private func handle(action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            sendBreakoutNotification()
            completionHandler(.defer)
        case .firstSecondarySubmenuItemPressed,
             .secondSecondarySubmenuItemPressed,
             .thirdSecondarySubmenuItemPressed:
            sendBreakoutNotification()
            completionHandler(.defer)
        @unknown default:
            completionHandler(.defer)
        }
    }

    private func sendBreakoutNotification() {
        let tapTarget = TapJailConstants.SharedFile.readTapTarget()

        let content = UNMutableNotificationContent()
        content.title = "Tap to enter TapJail"
        content.body = "Tap \(tapTarget) times to break out of TapJail."
        content.sound = .default
        content.userInfo = ["route": "prison"]

        let request = UNNotificationRequest(
            identifier: "tapjail.breakout",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        UNUserNotificationCenter.current().add(request)
    }
}
