import Foundation
import RevenueCat

@MainActor
final class PurchaseManager: NSObject, ObservableObject {

    static let shared = PurchaseManager()

    @Published private(set) var isPro: Bool = false
    @Published private(set) var hasLoadedCustomerInfo: Bool = false
    @Published private(set) var customerInfo: CustomerInfo?
    @Published private(set) var offerings: Offerings?
    @Published var isLoading: Bool = false
    @Published var purchaseError: PurchaseManagerError?

    private override init() {
        super.init()
        Purchases.shared.delegate = self
        Task { await refresh() }
    }

    // MARK: - Refresh

    func refresh() async {
        if let info = try? await Purchases.shared.customerInfo() {
            apply(info)
        }
        hasLoadedCustomerInfo = true

        if let fetched = try? await Purchases.shared.offerings() {
            offerings = fetched
        }
    }

    // MARK: - Purchase

    func purchase(package: Package) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await Purchases.shared.purchase(package: package)
            guard !result.userCancelled else { return }
            apply(result.customerInfo)
        } catch {
            purchaseError = PurchaseManagerError(error)
        }
    }

    // MARK: - Restore

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let info = try await Purchases.shared.restorePurchases()
            apply(info)
        } catch {
            purchaseError = PurchaseManagerError(error)
        }
    }

    // MARK: - Entitlement check

    func isEntitled(_ entitlement: String = TapJailConstants.RevenueCat.proEntitlement) -> Bool {
        customerInfo?.entitlements[entitlement]?.isActive == true
    }

    func updateCustomerInfo(_ info: CustomerInfo) {
        apply(info)
    }

    // MARK: - Private

    private func apply(_ info: CustomerInfo) {
        customerInfo = info
        isPro = info.entitlements[TapJailConstants.RevenueCat.proEntitlement]?.isActive == true
        hasLoadedCustomerInfo = true
    }
}

// MARK: - PurchasesDelegate

extension PurchaseManager: PurchasesDelegate {
    nonisolated func purchases(
        _ purchases: Purchases,
        receivedUpdated customerInfo: CustomerInfo
    ) {
        Task { @MainActor in self.apply(customerInfo) }
    }
}

// MARK: - Error

struct PurchaseManagerError: LocalizedError, Identifiable {
    let id = UUID()
    let message: String

    init(_ error: Error) {
        message = error.localizedDescription
    }

    var errorDescription: String? { message }
}
