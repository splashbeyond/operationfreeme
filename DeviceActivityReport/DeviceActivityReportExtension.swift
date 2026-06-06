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

// MARK: - Scene

private struct BudgetReportScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .tapJailBudget
    let content: (BudgetReportConfiguration) -> BudgetReportView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> BudgetReportConfiguration {
        var elapsed: TimeInterval = 0
        var appRows: [AppUsageRow] = []

        for await activityData in data {
            for await segment in activityData.activitySegments {
                elapsed += segment.totalActivityDuration

                for await category in segment.categories {
                    for await app in category.applications {
                        let duration = app.totalActivityDuration
                        guard duration >= 60 else { continue }
                        let token = app.application.token
                        let name = (app.application.localizedDisplayName ?? "Unknown App")
                        appRows.append(AppUsageRow(token: token, name: name, duration: duration))
                    }
                }
            }
        }

        // Merge duplicates and sort descending
        var merged: [String: AppUsageRow] = [:]
        for row in appRows {
            if var existing = merged[row.name] {
                existing.duration += row.duration
                merged[row.name] = existing
            } else {
                merged[row.name] = row
            }
        }
        let sortedApps = merged.values.sorted { $0.duration > $1.duration }

        let budgetMinutes = loadBudgetMinutes()
        return BudgetReportConfiguration(
            elapsed: elapsed,
            budget: TimeInterval(budgetMinutes * 60),
            apps: Array(sortedApps.prefix(8))
        )
    }

    private func loadBudgetMinutes() -> Int {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.piperstudio.tapjail"
        ) else { return 60 }

        let url = containerURL.appendingPathComponent("TapJailReportConfiguration.plist")
        guard let data = try? Data(contentsOf: url),
              let configuration = try? PropertyListSerialization.propertyList(
                from: data, options: [], format: nil
              ) as? [String: Any],
              let budgetMinutes = configuration["budgetMinutes"] as? Int,
              budgetMinutes > 0 else { return 60 }
        return budgetMinutes
    }
}

// MARK: - Models

struct AppUsageRow: Identifiable {
    let id = UUID()
    var token: ApplicationToken?
    let name: String
    var duration: TimeInterval
}

struct BudgetReportConfiguration {
    let elapsed: TimeInterval
    let budget: TimeInterval
    let apps: [AppUsageRow]

    var remaining: TimeInterval { max(0, budget - elapsed) }
    var progress: Double {
        guard budget > 0 else { return 0 }
        return min(max(elapsed / budget, 0), 1)
    }
}

// MARK: - Views

private struct BudgetReportView: View {
    let configuration: BudgetReportConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Remaining / elapsed header
            VStack(alignment: .leading, spacing: 3) {
                Text(remainingText)
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(white)
                    .monospacedDigit()
                    .minimumScaleFactor(0.72)

                Text(configuration.remaining > 0 ? "remaining today" : "daily budget reached")
                    .font(.system(size: 16))
                    .foregroundStyle(muted)
            }

            // Progress bar
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(raised)
                    Capsule()
                        .fill(configuration.progress >= 1 ? red : green)
                        .frame(
                            width: max(
                                configuration.progress > 0 ? 8 : 0,
                                proxy.size.width * configuration.progress
                            )
                        )
                }
            }
            .frame(height: 8)

            // Per-app breakdown
            if !configuration.apps.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("BY APP")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(muted)
                        .tracking(1.2)
                        .padding(.bottom, 10)

                    ForEach(Array(configuration.apps.enumerated()), id: \.element.id) { i, app in
                        if i > 0 {
                            Divider()
                                .overlay(dividerColor)
                        }
                        appRow(app)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            configuration.remaining > 0
                ? "\(remainingText) remaining in today's budget"
                : "Today's budget reached"
        )
    }

    private func appRow(_ app: AppUsageRow) -> some View {
        HStack(spacing: 12) {
            if let token = app.token {
                Label(token)
                    .labelStyle(.iconOnly)
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            } else {
                Image(systemName: "app.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(muted)
                    .frame(width: 28, height: 28)
            }

            Text(app.name)
                .font(.system(size: 15))
                .foregroundStyle(white)
                .lineLimit(1)

            Spacer()

            Text(shortDuration(app.duration))
                .font(.system(size: 15, weight: .medium).monospacedDigit())
                .foregroundStyle(muted)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Helpers

    private var remainingText: String {
        let totalSeconds = Int(configuration.remaining.rounded(.down))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 { return "\(hours) hr \(minutes) min" }
        if minutes == 0, seconds > 0 { return "\(seconds) sec" }
        return "\(minutes) min"
    }

    private func shortDuration(_ t: TimeInterval) -> String {
        let s = Int(t.rounded(.down))
        let h = s / 3_600
        let m = (s % 3_600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }

    // Hardcoded TapJailColor values (extension can't import the main target)
    private let white      = Color(red: 240/255, green: 240/255, blue: 234/255)
    private let muted      = Color(red: 184/255, green: 184/255, blue: 178/255)
    private let raised     = Color(red:  48/255, green:  48/255, blue:  48/255)
    private let green      = Color(red:  16/255, green: 163/255, blue: 127/255)
    private let red        = Color(red: 229/255, green:  72/255, blue:  77/255)
    private let dividerColor = Color(red: 64/255, green: 64/255, blue: 64/255)
}

// MARK: - Context

private extension DeviceActivityReport.Context {
    static let tapJailBudget = Self("tapjail.budget")
}
