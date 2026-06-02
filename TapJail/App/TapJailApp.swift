import SwiftUI
import UIKit
import UserNotifications

@main
struct TapJailApp: App {
    @UIApplicationDelegateAdaptor(TapJailAppDelegate.self) private var appDelegate
    @StateObject private var jail = JailController()
    @State private var route: AppRoute = .lock

    var body: some Scene {
        WindowGroup {
            RootView(route: $route)
                .environmentObject(jail)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    guard url.scheme == TapJailConstants.urlScheme else { return }
                    if url.host == "prison" || url.path == "/prison" {
                        route = .prison
                    }
                }
                .onAppear {
                    if jail.isLockActive || ProcessInfo.processInfo.arguments.contains("-tapjail-prison") {
                        route = .prison
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .tapJailOpenPrison)) { _ in
                    route = .prison
                }
        }
    }
}

enum AppRoute {
    case lock
    case prison
}

final class TapJailAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        guard userInfo["route"] as? String == "prison" else { return }

        await MainActor.run {
            NotificationCenter.default.post(name: .tapJailOpenPrison, object: nil)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}

extension Notification.Name {
    static let tapJailOpenPrison = Notification.Name("tapJailOpenPrison")
}
