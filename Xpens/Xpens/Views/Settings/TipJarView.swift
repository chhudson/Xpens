import SwiftUI
import StoreKit

struct TipJarView: View {
    @StateObject private var service = TipJarService()

    var body: some View {
        VStack(spacing: 20) {
            if service.hasRecentlyTipped || service.purchaseState == .purchased {
                thankYouView
            } else {
                tipOptionsView
            }
        }
        .padding()
        .navigationTitle("Tip Jar")
        .task {
            await service.loadProducts()
        }
    }

    // MARK: - Subviews

    private var tipOptionsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.fill")
                .font(.system(size: 44))
                .foregroundStyle(.pink)

            Text("Xpens is free forever.")
                .font(.title2.bold())

            Text("If it's saved you time, consider leaving a tip! Every bit helps support development.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if service.products.isEmpty {
                ProgressView("Loading...")
            } else {
                VStack(spacing: 12) {
                    ForEach(service.products, id: \.id) { product in
                        tipButton(for: product)
                    }
                }
                .padding(.top, 8)
            }

            if case .failed(let message) = service.purchaseState {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private func tipButton(for product: Product) -> some View {
        let tipProduct = TipJarProduct(rawValue: product.id)

        return Button {
            Task { await service.purchase(product) }
        } label: {
            HStack {
                Text(tipProduct?.emoji ?? "💰")
                    .font(.title2)
                Text(tipProduct?.label ?? product.displayName)
                    .fontWeight(.medium)
                Spacer()
                Text(product.displayPrice)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(.fill.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(service.purchaseState == .purchasing)
    }

    private var thankYouView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.pink)

            Text("Thank You!")
                .font(.title.bold())

            Text("Your generosity means the world. Enjoy using Xpens!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 40)
    }
}
