import Foundation

@main
enum RunBudgetPolicyTests {
    static func main() {
        var failures: [String] = []
        let expectedMinutes = Array(stride(from: 15, through: 480, by: 15))

        check(
            BudgetPolicy.supportedMinutes == expectedMinutes,
            "supported limits must contain every 15-minute value from 15 through 480",
            failures: &failures
        )

        for minutes in expectedMinutes {
            check(
                BudgetPolicy.normalizedMinutes(minutes) == minutes,
                "\(minutes)-minute limits must schedule without changing the threshold",
                failures: &failures
            )
        }

        let normalizationCases = [
            (-1, 15),
            (0, 15),
            (14, 15),
            (15, 15),
            (22, 15),
            (23, 30),
            (472, 465),
            (473, 480),
            (480, 480),
            (999, 480)
        ]

        for (input, expected) in normalizationCases {
            check(
                BudgetPolicy.normalizedMinutes(input) == expected,
                "\(input) minutes must normalize to \(expected)",
                failures: &failures
            )
        }

        let expectedTapTargets = [100, 200, 400, 800, 1_000, 1_000]
        for (stage, expected) in expectedTapTargets.enumerated() {
            check(
                BudgetPolicy.tapsRequired(for: stage) == expected,
                "stage \(stage) must require \(expected) taps",
                failures: &failures
            )
        }

        check(
            BudgetPolicy.extensionMinutes == 15,
            "normal breakouts must grant 15 minutes",
            failures: &failures
        )

        guard failures.isEmpty else {
            for failure in failures {
                FileHandle.standardError.write(Data("FAIL: \(failure)\n".utf8))
            }
            exit(1)
        }

        print("PASS: validated all \(expectedMinutes.count) daily limits (15...480 minutes)")
        print("PASS: validated normalization boundaries and escalation targets")
    }

    private static func check(
        _ condition: @autoclosure () -> Bool,
        _ message: String,
        failures: inout [String]
    ) {
        if !condition() {
            failures.append(message)
        }
    }
}
