import SwiftUI

struct RootView: View {
    @Binding var route: AppRoute
    @EnvironmentObject private var jail: JailController

    var body: some View {
        ZStack {
            TapJailColor.black.ignoresSafeArea()

            switch route {
            case .lock:
                LockView(route: $route)
            case .prison:
                TapPrisonView(route: $route)
            }
        }
        .onChange(of: jail.isLockActive) { _, isActive in
            if isActive {
                route = .prison
            }
        }
    }
}

enum TapJailColor {
    static let black = Color.black
    static let white = Color.white
    static let red = Color(red: 209 / 255, green: 0, blue: 0)
    static let row = Color.white.opacity(0.06)
    static let divider = Color.white.opacity(0.15)
    static let muted = Color.white.opacity(0.6)
}

extension Font {
    static func tapJail(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
}

