import SwiftUI
import RevenueCatUI

// Customer Center handles: manage subscription, cancel, restore purchases,
// and contact support — all from RevenueCat's pre-built UI.
// Present this from a settings/account screen.
struct CustomerCenterSheet: View {
    var body: some View {
        CustomerCenterView()
    }
}

// MARK: - Convenience modifier

extension View {
    /// Adds a "Manage Subscription" button that opens the Customer Center.
    func customerCenterButton(label: String = "Manage Subscription") -> some View {
        self.modifier(CustomerCenterButtonModifier(label: label))
    }
}

private struct CustomerCenterButtonModifier: ViewModifier {
    let label: String
    @State private var show = false

    func body(content: Content) -> some View {
        VStack {
            content
            Button(label) { show = true }
            .sheet(isPresented: $show) {
                CustomerCenterSheet()
            }
        }
    }
}
