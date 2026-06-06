import DeviceActivity
import SwiftUI

@main
struct TapJailDeviceActivityReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TrackingReportScene { configuration in
            TrackingReportView(configuration: configuration)
        }
    }
}

// MARK: - Scene

private struct TrackingReportScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .tapJailTracking
    let content: (TrackingReportConfiguration) -> TrackingReportView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> TrackingReportConfiguration {
        var elapsed: TimeInterval = 0

        for await activityData in data {
            for await segment in activityData.activitySegments {
                elapsed += segment.totalActivityDuration
            }
        }

        return TrackingReportConfiguration(elapsed: elapsed)
    }
}

// MARK: - Model

struct TrackingReportConfiguration {
    let elapsed: TimeInterval
}

// MARK: - View

private struct TrackingReportView: View {
    let configuration: TrackingReportConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(elapsedText)
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(white)
                .monospacedDigit()
                .minimumScaleFactor(0.72)

            Text("screen time today")
                .font(.system(size: 16))
                .foregroundStyle(muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(elapsedText) of screen time today")
    }

    private var elapsedText: String {
        let s = Int(configuration.elapsed.rounded(.down))
        let h = s / 3_600
        let m = (s % 3_600) / 60
        if h > 0 { return "\(h) hr \(m) min" }
        if m == 0 { return "0 min" }
        return "\(m) min"
    }

    private let white = Color(red: 240/255, green: 240/255, blue: 234/255)
    private let muted = Color(red: 184/255, green: 184/255, blue: 178/255)
}

// MARK: - Context

private extension DeviceActivityReport.Context {
    static let tapJailTracking = Self("tapjail.daily-tracking")
}
