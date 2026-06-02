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
            backgroundColor: .black,
            title: ShieldConfiguration.Label(text: "You are in TapJail.", color: .white),
            subtitle: ShieldConfiguration.Label(
                text: "You used your time. Pay the toll to break out.",
                color: UIColor.white.withAlphaComponent(0.7)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Break Out of TapJail", color: .white),
            primaryButtonBackgroundColor: UIColor(red: 209 / 255, green: 0, blue: 0, alpha: 1),
            secondaryButtonLabel: ShieldConfiguration.Label(text: "I'm done.", color: .white)
        )
    }
}

