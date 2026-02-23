import SwiftUI

struct CurrencyTextField: View {
    let title: String
    @Binding var amount: Decimal?
    @State private var text: String = ""

    var body: some View {
        HStack(spacing: 4) {
            Text("$")
                .foregroundStyle(.secondary)
            TextField(title, text: $text)
                .keyboardType(.decimalPad)
                .onChange(of: text) { _, newValue in
                    amount = CurrencyFormatter.decimal(from: newValue)
                }
        }
        .onAppear {
            if let amount {
                text = "\(amount)"
            }
        }
    }
}
