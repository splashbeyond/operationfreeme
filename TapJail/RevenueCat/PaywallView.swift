import SwiftUI
import RevenueCat
import RevenueCatUI

// Full-screen paywall — present this whenever a Pro feature is gated.
// RevenueCatUI renders the template configured in the RevenueCat dashboard,
// so no hard-coded UI is needed here.
struct TapJailPaywallView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PaywallView(displayCloseButton: true)
            .onPurchaseCompleted { customerInfo in
                if customerInfo.entitlements[TapJailConstants.RevenueCat.proEntitlement]?.isActive == true {
                    dismiss()
                }
            }
            .onRestoreCompleted { customerInfo in
                if customerInfo.entitlements[TapJailConstants.RevenueCat.proEntitlement]?.isActive == true {
                    dismiss()
                }
            }
    }
}

// MARK: - Convenience modifier

extension View {
    /// Gate any view behind the Pro entitlement.
    /// Shows the paywall automatically if the user is not subscribed.
    func requiresPro() -> some View {
        self.modifier(ProEntitlementModifier())
    }
}

private struct ProEntitlementModifier: ViewModifier {
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showPaywall = false

    func body(content: Content) -> some View {
        content
            .disabled(!purchases.isPro)
            .onTapGesture {
                if !purchases.isPro { showPaywall = true }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                TapJailPaywallView()
            }
    }
}
