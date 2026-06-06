import FamilyControls
import SwiftUI

struct LockView: View {
    @Binding var route: AppRoute
    @EnvironmentObject private var jail: JailController
    @State private var isPickerPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TapJail")
                            .font(.tapJail(52, weight: .bold))
                            .foregroundStyle(TapJailColor.white)

                        Text(jail.isLockActive ? "You are locked in." : "Choose the apps. Start the lock.")
                            .font(.tapJail(17, weight: .light))
                            .foregroundStyle(TapJailColor.muted)
                    }
                }

                statusPanel
                selectionPanel
                budgetPanel
                controls

                if let errorMessage = jail.errorMessage {
                    Text(errorMessage)
                        .font(.tapJail(15, weight: .bold))
                        .foregroundStyle(TapJailColor.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(TapJailColor.black)
        .familyActivityPicker(
            headerText: "Choose what TapJail blocks.",
            footerText: "These selections stay on this device.",
            isPresented: $isPickerPresented,
            selection: $jail.selection
        )
        .onChange(of: isPickerPresented) { _, isPresented in
            if !isPresented {
                jail.saveSelection()
            }
        }
        .onAppear {
            jail.refreshAuthorizationStatus()
            jail.refreshSharedState()
        }
    }

    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Screen Time")
                .font(.tapJail(22, weight: .bold))

            Text(authorizationCopy)
                .font(.tapJail(15, weight: .light))
                .foregroundStyle(TapJailColor.muted)

            if !hasScreenTimeAuthorization {
                Button {
                    Task { await jail.requestAuthorization() }
                } label: {
                    Text("Authorize Screen Time")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TapJailPrimaryButtonStyle())
            }
        }
        .panelStyle()
    }

    private var selectionPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Locked Apps")
                .font(.tapJail(22, weight: .bold))

            Text(jail.selectionSummary)
                .font(.tapJail(15, weight: .light))
                .foregroundStyle(TapJailColor.muted)

            Button {
                isPickerPresented = true
            } label: {
                Text("Choose Apps")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TapJailSecondaryButtonStyle())
        }
        .panelStyle()
    }

    private var controls: some View {
        VStack(spacing: 12) {
            Button {
                jail.lockNow()
            } label: {
                Text("Lock Now")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TapJailPrimaryButtonStyle())
            .disabled(!hasScreenTimeAuthorization || !jail.hasSelection)

            Button {
                route = .prison
            } label: {
                Text("Enter Tap Prison")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TapJailSecondaryButtonStyle())
            .disabled(!jail.isLockActive)

            Button {
                jail.unlock()
            } label: {
                Text("Unlock")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TapJailDestructiveButtonStyle())

            Button {
                jail.sendPrisonRouteTestNotification()
            } label: {
                Text("Test Prison Notification")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TapJailSecondaryButtonStyle())
        }
    }

    private var budgetPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Budget")
                    .font(.tapJail(22, weight: .bold))

                Spacer()

                Text(budgetDurationText)
                    .font(.tapJail(17, weight: .bold))
                    .foregroundStyle(TapJailColor.green)
            }

            Text("Usage is shared across everything selected above and resets at midnight.")
                .font(.tapJail(15, weight: .light))
                .foregroundStyle(TapJailColor.muted)

            Slider(
                value: Binding(
                    get: { Double(jail.dailyBudgetMinutes) },
                    set: { jail.dailyBudgetMinutes = Int($0) }
                ),
                in: budgetRange,
                step: Double(TapJailConstants.DeviceActivity.budgetStepMinutes)
            )
            .tint(TapJailColor.green)
            .accessibilityLabel("Daily app budget")
            .accessibilityValue(budgetDurationText)

            Button {
                jail.startDailyBudget()
            } label: {
                Text(jail.isBudgetMonitoring ? "Update Daily Budget" : "Start Daily Budget")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TapJailPrimaryButtonStyle())
            .disabled(!hasScreenTimeAuthorization || !jail.hasSelection)

#if DEBUG
            Button {
                jail.startDailyBudget(minutes: 1)
            } label: {
                Text("Start 1-Minute Device Test")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TapJailSecondaryButtonStyle())
            .disabled(!hasScreenTimeAuthorization || !jail.hasSelection)

            if jail.isBudgetMonitoring {
                Button {
                    jail.stopDailyBudget()
                } label: {
                    Text("Stop Budget Test")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TapJailDestructiveButtonStyle())
            }
#endif
        }
        .panelStyle()
    }

    private var budgetDurationText: String {
        let hours = jail.dailyBudgetMinutes / 60
        let minutes = jail.dailyBudgetMinutes % 60

        if hours == 0 {
            return "\(minutes) min"
        }
        if minutes == 0 {
            return "\(hours) hr"
        }
        return "\(hours) hr \(minutes) min"
    }

    private var budgetRange: ClosedRange<Double> {
        let minimum = Double(TapJailConstants.DeviceActivity.minimumBudgetMinutes)
        let maximum = Double(TapJailConstants.DeviceActivity.maximumBudgetMinutes)
        return minimum...maximum
    }

    private var authorizationCopy: String {
        switch jail.authorizationStatus {
        case .notDetermined:
            return "Authorization has not been granted."
        case .denied:
            return "Authorization was denied."
        case .approved, .approvedWithDataAccess:
            return "Authorization approved."
        @unknown default:
            return "Authorization status unknown."
        }
    }

    private var hasScreenTimeAuthorization: Bool {
        switch jail.authorizationStatus {
        case .approved, .approvedWithDataAccess:
            return true
        default:
            return false
        }
    }
}

private extension View {
    func panelStyle() -> some View {
        self
            .foregroundStyle(TapJailColor.white)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TapJailColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(TapJailColor.divider, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct TapJailPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tapJail(17, weight: .bold))
            .foregroundStyle(TapJailColor.black)
            .padding(.vertical, 16)
            .background(TapJailColor.green.opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

struct TapJailSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tapJail(17, weight: .bold))
            .foregroundStyle(TapJailColor.white)
            .padding(.vertical, 16)
            .background(TapJailColor.row.opacity(configuration.isPressed ? 0.72 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TapJailColor.divider, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

struct TapJailDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tapJail(17, weight: .bold))
            .foregroundStyle(TapJailColor.red)
            .padding(.vertical, 16)
            .background(TapJailColor.surface.opacity(configuration.isPressed ? 0.72 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TapJailColor.red.opacity(0.65), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}
