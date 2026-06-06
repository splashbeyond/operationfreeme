import DeviceActivity
import SwiftUI

@main
struct TapJailDeviceActivityReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        BudgetReportScene { configuration in
            BudgetReportView(configuration: configuration)
        }
    }
}

private struct BudgetReportScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .tapJailBudget
    let content: (BudgetReportConfiguration) -> BudgetReportView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> BudgetReportConfiguration {
        var elapsed: TimeInterval = 0

        for await activityData in data {
            for await segment in activityData.activitySegments {
                elapsed += segment.totalActivityDuration
            }
        }

        let defaults = UserDefaults(suiteName: "group.com.piperstudio.tapjail")
        let activeBudget = defaults?.integer(forKey: "activeBudgetMinutes") ?? 0
        let savedBudget = activeBudget > 0
            ? activeBudget
            : defaults?.integer(forKey: "dailyBudgetMinutes") ?? 0
        let budgetMinutes = savedBudget > 0 ? savedBudget : 60

        return BudgetReportConfiguration(
            elapsed: elapsed,
            budget: TimeInterval(budgetMinutes * 60)
        )
    }
}

private struct BudgetReportConfiguration {
    let elapsed: TimeInterval
    let budget: TimeInterval

    var remaining: TimeInterval {
        max(0, budget - elapsed)
    }

    var progress: Double {
        guard budget > 0 else { return 0 }
        return min(max(elapsed / budget, 0), 1)
    }
}

private struct BudgetReportView: View {
    let configuration: BudgetReportConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(remainingText)
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(Color(red: 240 / 255, green: 240 / 255, blue: 234 / 255))
                    .monospacedDigit()
                    .minimumScaleFactor(0.72)

                Text(configuration.remaining > 0 ? "remaining today" : "daily budget reached")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 184 / 255, green: 184 / 255, blue: 178 / 255))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 48 / 255, green: 48 / 255, blue: 48 / 255))

                    Capsule()
                        .fill(configuration.progress >= 1
                            ? Color(red: 229 / 255, green: 72 / 255, blue: 77 / 255)
                            : Color(red: 16 / 255, green: 163 / 255, blue: 127 / 255))
                        .frame(
                            width: max(
                                configuration.progress > 0 ? 8 : 0,
                                proxy.size.width * configuration.progress
                            )
                        )
                }
            }
            .frame(height: 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            configuration.remaining > 0
                ? "\(remainingText) remaining in today's budget"
                : "Today's budget reached"
        )
    }

    private var remainingText: String {
        let totalSeconds = Int(configuration.remaining.rounded(.down))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        }
        if minutes == 0, seconds > 0 {
            return "\(seconds) sec"
        }
        return "\(minutes) min"
    }
}

private extension DeviceActivityReport.Context {
    static let tapJailBudget = Self("tapjail.budget")
}
