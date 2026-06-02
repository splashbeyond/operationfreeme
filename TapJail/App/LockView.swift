import FamilyControls
import SwiftUI

struct LockView: View {
    @Binding var route: AppRoute
    @EnvironmentObject private var jail: JailController
    @State private var isPickerPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("TapJail")
                        .font(.tapJail(48))
                        .foregroundStyle(TapJailColor.white)

                    Text(jail.isLockActive ? "You are locked in." : "Select the apps. Lock in.")
                        .font(.tapJail(17))
                        .foregroundStyle(TapJailColor.muted)
                }

                statusPanel
                selectionPanel
                controls

                if let errorMessage = jail.errorMessage {
                    Text(errorMessage)
                        .font(.tapJail(15))
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
        }
    }

    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Screen Time")
                .font(.tapJail(22))

            Text(authorizationCopy)
                .font(.tapJail(15))
                .foregroundStyle(TapJailColor.muted)

            if jail.authorizationStatus != .approved {
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
                .font(.tapJail(22))

            Text(jail.selectionSummary)
                .font(.tapJail(15))
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
            .disabled(jail.authorizationStatus != .approved || !jail.hasSelection)

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
            .buttonStyle(TapJailSecondaryButtonStyle())

            Button {
                jail.sendPrisonRouteTestNotification()
            } label: {
                Text("Test Prison Notification")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TapJailSecondaryButtonStyle())
        }
    }

    private var authorizationCopy: String {
        switch jail.authorizationStatus {
        case .notDetermined:
            return "Authorization has not been granted."
        case .denied:
            return "Authorization was denied."
        case .approved:
            return "Authorization approved."
        @unknown default:
            return "Authorization status unknown."
        }
    }
}

private extension View {
    func panelStyle() -> some View {
        self
            .foregroundStyle(TapJailColor.white)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TapJailColor.row)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct TapJailPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tapJail(17))
            .foregroundStyle(TapJailColor.white)
            .padding(.vertical, 16)
            .background(TapJailColor.red.opacity(configuration.isPressed ? 0.82 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

struct TapJailSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tapJail(17))
            .foregroundStyle(TapJailColor.white)
            .padding(.vertical, 16)
            .background(TapJailColor.black)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TapJailColor.white, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}
