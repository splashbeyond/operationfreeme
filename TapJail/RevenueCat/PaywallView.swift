import RevenueCat
import SwiftUI

struct TapJailPaywallView: View {
    @EnvironmentObject private var purchases: PurchaseManager

    var onEntitlementUnlocked: (() -> Void)?

    @State private var selectedPackageIdentifier: String?

    private var packages: [Package] {
        let availablePackages = purchases.offerings?.current?.availablePackages ?? []

        return availablePackages
            .filter { package in
                isYearly(package) || isWeekly(package)
            }
            .sorted { lhs, rhs in
                isYearly(lhs) && !isYearly(rhs)
            }
    }

    private var selectedPackage: Package? {
        packages.first { $0.identifier == selectedPackageIdentifier }
            ?? packages.first
    }

    var body: some View {
        ZStack {
            TapJailColor.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header

                    if packages.isEmpty {
                        unavailableState
                    } else {
                        packageOptions

                        if let selectedPackage {
                            purchaseSummary(for: selectedPackage)
                            purchaseButton(for: selectedPackage)
                            renewalDisclosure(for: selectedPackage)
                        }
                    }

                    restoreButton
                    legalLinks
                }
                .frame(maxWidth: 560)
                .padding(.horizontal, 20)
                .padding(.top, 36)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity)
            }

            if purchases.isLoading {
                TapJailColor.black.opacity(0.55).ignoresSafeArea()
                ProgressView()
                    .controlSize(.large)
                    .tint(TapJailColor.green)
            }
        }
        .task {
            if purchases.offerings == nil {
                await purchases.refresh()
            }
            selectDefaultPackage()
        }
        .onChange(of: packages.map(\.identifier)) { _, _ in
            selectDefaultPackage()
        }
        .onChange(of: purchases.isPro) { _, isPro in
            if isPro {
                onEntitlementUnlocked?()
            }
        }
        .alert(item: $purchases.purchaseError) { error in
            Alert(
                title: Text("Purchase issue"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image("TapJailIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text("Unlock TapJail Pro")
                .font(.tapJail(30, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .multilineTextAlignment(.center)

            Text("Set daily app limits and use TapJail's full blocking experience.")
                .font(.tapJail(16))
                .foregroundStyle(TapJailColor.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var packageOptions: some View {
        VStack(spacing: 12) {
            ForEach(packages, id: \.identifier) { package in
                let isSelected = package.identifier == selectedPackage?.identifier

                Button {
                    selectedPackageIdentifier = package.identifier
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(isSelected ? TapJailColor.green : TapJailColor.muted)

                        VStack(alignment: .leading, spacing: 4) {
                            if isYearly(package) {
                                Text("80% OFF")
                                    .font(.tapJail(10, weight: .bold))
                                    .foregroundStyle(TapJailColor.black)
                                    .tracking(0.6)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(TapJailColor.green)
                                    .clipShape(Capsule())
                            }

                            Text(planName(for: package))
                                .font(.tapJail(17, weight: .bold))
                                .foregroundStyle(TapJailColor.white)

                            Text(billingDescription(for: package))
                                .font(.tapJail(13))
                                .foregroundStyle(TapJailColor.muted)
                        }

                        Spacer(minLength: 12)

                        Text(package.storeProduct.localizedPriceString)
                            .font(.tapJail(20, weight: .bold))
                            .foregroundStyle(TapJailColor.white)
                            .monospacedDigit()
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? TapJailColor.green.opacity(0.12) : TapJailColor.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isSelected ? TapJailColor.green : TapJailColor.divider,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    "\(planName(for: package)), \(billingDescription(for: package))"
                )
            }
        }
    }

    private func purchaseSummary(for package: Package) -> some View {
        VStack(spacing: 6) {
            Text("YOU WILL BE BILLED")
                .font(.tapJail(12, weight: .bold))
                .foregroundStyle(TapJailColor.muted)
                .tracking(1.2)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(package.storeProduct.localizedPriceString)
                    .font(.tapJail(46, weight: .bold))
                    .foregroundStyle(TapJailColor.white)
                    .monospacedDigit()

                Text(billingUnit(for: package))
                    .font(.tapJail(18, weight: .bold))
                    .foregroundStyle(TapJailColor.muted)
            }
            .accessibilityElement(children: .combine)

            Text(planName(for: package))
                .font(.tapJail(15))
                .foregroundStyle(TapJailColor.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(TapJailColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(TapJailColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func purchaseButton(for package: Package) -> some View {
        Button {
            Task {
                await purchases.purchase(package: package)
            }
        } label: {
            Text(purchaseButtonTitle(for: package))
                .font(.tapJail(17, weight: .bold))
                .foregroundStyle(TapJailColor.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(TapJailColor.green)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(purchases.isLoading)
    }

    private func renewalDisclosure(for package: Package) -> some View {
        Group {
            if isLifetime(package) {
                Text("This is a one-time purchase charged to your Apple ID.")
            } else {
                Text(
                    "Payment will be charged to your Apple ID at confirmation. "
                    + "The subscription automatically renews for \(package.storeProduct.localizedPriceString) "
                    + "\(billingUnit(for: package)) unless canceled at least 24 hours before the current period ends. "
                    + "Manage or cancel in your App Store account settings."
                )
            }
        }
        .font(.tapJail(12))
        .foregroundStyle(TapJailColor.muted)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var restoreButton: some View {
        Button {
            Task {
                await purchases.restore()
            }
        } label: {
            Text("Restore Purchases")
                .font(.tapJail(15, weight: .bold))
                .foregroundStyle(TapJailColor.white)
                .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
        .disabled(purchases.isLoading)
    }

    private var legalLinks: some View {
        HStack(spacing: 24) {
            Link("Privacy Policy", destination: TapJailConstants.Legal.privacyPolicyURL)
            Link("Terms of Use", destination: TapJailConstants.Legal.termsOfUseURL)
        }
        .font(.tapJail(13, weight: .bold))
        .foregroundStyle(TapJailColor.muted)
    }

    private var unavailableState: some View {
        VStack(spacing: 14) {
            Text("Subscriptions are unavailable right now.")
                .font(.tapJail(17, weight: .bold))
                .foregroundStyle(TapJailColor.white)

            Text("Check your connection and try again.")
                .font(.tapJail(14))
                .foregroundStyle(TapJailColor.muted)

            Button("Try Again") {
                Task {
                    await purchases.refresh()
                }
            }
            .font(.tapJail(15, weight: .bold))
            .foregroundStyle(TapJailColor.green)
            .frame(minHeight: 44)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(TapJailColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func selectDefaultPackage() {
        guard selectedPackageIdentifier == nil || selectedPackage == nil else {
            return
        }

        selectedPackageIdentifier = packages.first {
            $0.storeProduct.productIdentifier.lowercased().contains(
                TapJailConstants.RevenueCat.ProductID.yearly
            )
        }?.identifier ?? packages.first?.identifier
    }

    private func planName(for package: Package) -> String {
        let identifier = package.storeProduct.productIdentifier.lowercased()

        if identifier.contains(TapJailConstants.RevenueCat.ProductID.yearly) {
            return "TapJail Pro — Yearly"
        }
        if identifier.contains(TapJailConstants.RevenueCat.ProductID.monthly) {
            return "TapJail Pro — Monthly"
        }
        if identifier.contains(TapJailConstants.RevenueCat.ProductID.weekly) {
            return "TapJail Pro — Weekly"
        }
        if identifier.contains(TapJailConstants.RevenueCat.ProductID.lifetime) {
            return "TapJail Pro — Lifetime"
        }
        return package.storeProduct.localizedTitle
    }

    private func billingUnit(for package: Package) -> String {
        let identifier = package.storeProduct.productIdentifier.lowercased()

        if identifier.contains(TapJailConstants.RevenueCat.ProductID.yearly) {
            return "per year"
        }
        if identifier.contains(TapJailConstants.RevenueCat.ProductID.monthly) {
            return "per month"
        }
        if identifier.contains(TapJailConstants.RevenueCat.ProductID.weekly) {
            return "per week"
        }
        if identifier.contains(TapJailConstants.RevenueCat.ProductID.lifetime) {
            return "one time"
        }
        return "for this purchase"
    }

    private func billingDescription(for package: Package) -> String {
        if isLifetime(package) {
            return "One-time purchase"
        }

        return "Billed \(package.storeProduct.localizedPriceString) \(billingUnit(for: package))"
    }

    private func purchaseButtonTitle(for package: Package) -> String {
        if isLifetime(package) {
            return "Buy for \(package.storeProduct.localizedPriceString)"
        }

        return "Subscribe for \(package.storeProduct.localizedPriceString) \(billingUnit(for: package))"
    }

    private func isLifetime(_ package: Package) -> Bool {
        package.storeProduct.productIdentifier.lowercased().contains(
            TapJailConstants.RevenueCat.ProductID.lifetime
        )
    }

    private func isYearly(_ package: Package) -> Bool {
        package.storeProduct.productIdentifier.lowercased().contains(
            TapJailConstants.RevenueCat.ProductID.yearly
        )
    }

    private func isWeekly(_ package: Package) -> Bool {
        package.storeProduct.productIdentifier.lowercased().contains(
            TapJailConstants.RevenueCat.ProductID.weekly
        )
    }
}

extension View {
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
                if !purchases.isPro {
                    showPaywall = true
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                TapJailPaywallView()
            }
            .onChange(of: purchases.isPro) { _, isPro in
                if isPro {
                    showPaywall = false
                }
            }
    }
}
