import SwiftUI

struct CurrencySelectionPageView: View {
    @Binding var selectedCode: String

    private let currencies = CurrencyPickerView.commonCurrencies

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Choose Your Currency")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("You can change this later in Settings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 32)

            List(currencies, id: \.code) { currency in
                Button {
                    selectedCode = currency.code
                } label: {
                    HStack {
                        Text(currency.code)
                            .fontWeight(.semibold)
                            .frame(width: 50, alignment: .leading)
                        Text(currency.name)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if currency.code == selectedCode {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
            .listStyle(.plain)
        }
    }
}
