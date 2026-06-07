import SwiftUI
import UIKit
import UserNotifications
import RevenueCat

@main
struct TapJailApp: App {
    @UIApplicationDelegateAdaptor(TapJailAppDelegate.self) private var appDelegate
    @StateObject private var jail = JailController()
    @StateObject private var purchases = PurchaseManager.shared

    init() {
        Purchases.configure(withAPIKey: TapJailConstants.RevenueCat.apiKey)
    }

    @State private var route: AppRoute = .lock

    var body: some Scene {
        WindowGroup {
            RootView(route: $route)
                .environmentObject(jail)
                .environmentObject(purchases)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    guard url.scheme == TapJailConstants.urlScheme else { return }
                    if url.host == "prison" || url.path == "/prison" {
                        route = .prison
                    }
                }
                .onAppear {
                    if !jail.hasSeenOnboarding {
                        route = .onboarding
                    } else if jail.isLockActive || ProcessInfo.processInfo.arguments.contains("-tapjail-prison") {
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
    case onboarding
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
