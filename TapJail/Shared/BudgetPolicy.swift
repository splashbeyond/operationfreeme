import Foundation

enum BudgetPolicy {
    static let extensionMinutes = 15
    static let minimumMinutes = 15
    static let maximumMinutes = 480
    static let stepMinutes = 15

    static var supportedMinutes: [Int] {
        Array(
            stride(
                from: minimumMinutes,
                through: maximumMinutes,
                by: stepMinutes
            )
        )
    }

    static func normalizedMinutes(_ minutes: Int) -> Int {
        let clamped = min(max(minutes, minimumMinutes), maximumMinutes)
        let steps = Int(
            (Double(clamped) / Double(stepMinutes)).rounded()
        )
        return steps * stepMinutes
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
