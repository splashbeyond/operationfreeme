import ManagedSettings
import ManagedSettingsUI
import UIKit

final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        configuration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        configuration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        configuration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        configuration()
    }

    private func configuration() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: nil,
            backgroundColor: TapJailShieldColor.black,
            title: ShieldConfiguration.Label(text: "You are in TapJail.", color: TapJailShieldColor.white),
            subtitle: ShieldConfiguration.Label(
                text: "You used your time. Pay the toll to break out.",
                color: TapJailShieldColor.muted
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Break Out of TapJail", color: TapJailShieldColor.black),
            primaryButtonBackgroundColor: TapJailShieldColor.green,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "I'm done.", color: TapJailShieldColor.white)
        )
    }
}

private enum TapJailShieldColor {
    static let black = UIColor(red: 8 / 255, green: 9 / 255, blue: 10 / 255, alpha: 1)
    static let white = UIColor(red: 240 / 255, green: 240 / 255, blue: 234 / 255, alpha: 1)
    static let muted = UIColor(red: 184 / 255, green: 184 / 255, blue: 178 / 255, alpha: 1)
    static let green = UIColor(red: 16 / 255, green: 163 / 255, blue: 127 / 255, alpha: 1)
}
