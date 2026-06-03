import SwiftUI
import UIKit

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
    static let black = Color(red: 8 / 255, green: 9 / 255, blue: 10 / 255)
    static let surface = Color(red: 22 / 255, green: 23 / 255, blue: 24 / 255)
    static let row = Color(red: 32 / 255, green: 32 / 255, blue: 32 / 255)
    static let raised = Color(red: 48 / 255, green: 48 / 255, blue: 48 / 255)
    static let divider = Color(red: 64 / 255, green: 64 / 255, blue: 64 / 255)
    static let white = Color(red: 240 / 255, green: 240 / 255, blue: 234 / 255)
    static let muted = Color(red: 184 / 255, green: 184 / 255, blue: 178 / 255)
    static let green = Color(red: 16 / 255, green: 163 / 255, blue: 127 / 255)
    static let blue = Color(red: 37 / 255, green: 99 / 255, blue: 235 / 255)
    static let red = Color(red: 229 / 255, green: 72 / 255, blue: 77 / 255)

    static let uiBlack = UIColor(red: 8 / 255, green: 9 / 255, blue: 10 / 255, alpha: 1)
    static let uiSurface = UIColor(red: 22 / 255, green: 23 / 255, blue: 24 / 255, alpha: 1)
    static let uiWhite = UIColor(red: 240 / 255, green: 240 / 255, blue: 234 / 255, alpha: 1)
    static let uiMuted = UIColor(red: 184 / 255, green: 184 / 255, blue: 178 / 255, alpha: 1)
    static let uiGreen = UIColor(red: 16 / 255, green: 163 / 255, blue: 127 / 255, alpha: 1)
    static let uiRed = UIColor(red: 229 / 255, green: 72 / 255, blue: 77 / 255, alpha: 1)
}

extension Font {
    enum TapJailWeight {
        case light
        case regular
        case bold

        var systemWeight: Font.Weight {
            switch self {
            case .light:
                return .light
            case .regular:
                return .regular
            case .bold:
                return .bold
            }
        }

        var fontNames: [String] {
            switch self {
            case .light:
                return ["SchibstedGrotesk-Regular"]
            case .regular:
                return ["SchibstedGrotesk-Regular"]
            case .bold:
                return ["SchibstedGrotesk-Bold"]
            }
        }
    }

    static func tapJail(_ size: CGFloat, weight: TapJailWeight = .regular) -> Font {
        for fontName in weight.fontNames where UIFont(name: fontName, size: size) != nil {
            return .custom(fontName, size: size)
        }

        return .system(size: size, weight: weight.systemWeight, design: .default)
    }
}
