import StoreKit

enum TipJarProduct: String, CaseIterable {
    case coffee = "com.xpens.tip.coffee"
    case lunch = "com.xpens.tip.lunch"
    case dinner = "com.xpens.tip.dinner"

    var emoji: String {
        switch self {
        case .coffee: return "☕️"
        case .lunch: return "🥗"
        case .dinner: return "🍽️"
        }
    }

    var label: String {
        switch self {
        case .coffee: return "Coffee"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        }
    }
}

@MainActor
final class TipJarService: ObservableObject {

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchaseState: PurchaseState = .idle
    @Published private(set) var hasRecentlyTipped = false

    enum PurchaseState: Equatable {
        case idle
        case purchasing
        case purchased
        case failed(String)
    }

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            let ids = TipJarProduct.allCases.map(\.rawValue)
            let storeProducts = try await Product.products(for: ids)
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async {
        purchaseState = .purchasing
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                purchaseState = .purchased
                hasRecentlyTipped = true
            case .userCancelled:
                purchaseState = .idle
            case .pending:
                purchaseState = .idle
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }

    // MARK: - Private

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? self?.checkVerified(result) {
                    await transaction.finish()
                    await self?.markTipped()
                }
            }
        }
    }

    private func markTipped() {
        hasRecentlyTipped = true
    }
}
