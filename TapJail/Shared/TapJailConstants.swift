import DeviceActivity
import Foundation

enum TapJailConstants {
    static let appGroupID = "group.com.piperstudio.tapjail"
    static let urlScheme = "tapjail"
    static let prisonURL = URL(string: "tapjail://prison")!

    enum DeviceActivity {
        static let dailyBudget = DeviceActivityName("tapjail.daily-budget")
        static let extensionBudget = DeviceActivityName("tapjail.extension-budget")
        static let extensionMinutes = 15
        static let minimumBudgetMinutes = 15
        static let maximumBudgetMinutes = 240
        static let budgetStepMinutes = 15

        static var supportedBudgetMinutes: [Int] {
            Array(
                stride(
                    from: minimumBudgetMinutes,
                    through: maximumBudgetMinutes,
                    by: budgetStepMinutes
                )
            )
        }

        static func normalizedBudgetMinutes(_ minutes: Int) -> Int {
            let clamped = min(max(minutes, minimumBudgetMinutes), maximumBudgetMinutes)
            let steps = Int(
                (Double(clamped) / Double(budgetStepMinutes)).rounded()
            )
            return steps * budgetStepMinutes
        }

        static func event(for stage: Int) -> DeviceActivityEvent.Name {
            DeviceActivityEvent.Name("tapjail.breakout-stage-\(stage)")
        }

        static func stage(for event: DeviceActivityEvent.Name) -> Int? {
            let prefix = "tapjail.breakout-stage-"
            guard event.rawValue.hasPrefix(prefix) else { return nil }
            return Int(event.rawValue.dropFirst(prefix.count))
        }

        static func tapsRequired(for stage: Int) -> Int {
            switch stage {
            case 0:
                return 100
            case 1:
                return 200
            case 2:
                return 400
            case 3:
                return 800
            default:
                return 1_000
            }
        }
    }

    enum StorageKey {
        static let selectedActivitySelection = "selectedActivitySelection"
        static let isLockActive = "isLockActive"
        static let tapTarget = "tapTarget"
        static let sessionStartedAt = "sessionStartedAt"
        static let dailyBudgetMinutes = "dailyBudgetMinutes"
        static let isBudgetMonitoring = "isBudgetMonitoring"
        static let budgetDayIdentifier = "budgetDayIdentifier"
        static let budgetThresholdReached = "budgetThresholdReached"
        static let budgetThresholdReachedAt = "budgetThresholdReachedAt"
        static let breakoutStage = "breakoutStage"
        static let extensionMinutes = "extensionMinutes"
    }

    static func localDayIdentifier(for date: Date = Date()) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }
}
