import SwiftUI
import SwiftData

struct CurrencyPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allPreferences: [UserPreferences]

    @State private var searchText = ""
    @State private var showAll = false

    private var prefs: UserPreferences? { allPreferences.first }

    private var selectedCode: String {
        prefs?.currencyCode ?? "USD"
    }

    private var visibleCurrencies: [(code: String, name: String)] {
        let list = showAll ? Self.allCurrencies : Self.commonCurrencies
        if searchText.isEmpty { return list }
        let query = searchText.lowercased()
        return list.filter {
            $0.code.lowercased().contains(query) || $0.name.lowercased().contains(query)
        }
    }

    var body: some View {
        List {
            ForEach(visibleCurrencies, id: \.code) { currency in
                Button {
                    select(currency.code)
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

            if !showAll {
                Button("Show All Currencies") {
                    showAll = true
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search currencies")
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func select(_ code: String) {
        if let prefs {
            prefs.currencyCode = code
        } else {
            let newPrefs = UserPreferences(currencyCode: code)
            modelContext.insert(newPrefs)
        }
        CurrencyFormatter.setCurrency(code: code)
        dismiss()
    }

    // MARK: - Currency Data

    static let commonCurrencies: [(code: String, name: String)] = [
        ("USD", "US Dollar"),
        ("EUR", "Euro"),
        ("GBP", "British Pound"),
        ("CAD", "Canadian Dollar"),
        ("AUD", "Australian Dollar"),
        ("JPY", "Japanese Yen"),
        ("CHF", "Swiss Franc"),
        ("CNY", "Chinese Yuan"),
        ("SEK", "Swedish Krona"),
        ("NZD", "New Zealand Dollar"),
        ("MXN", "Mexican Peso"),
        ("SGD", "Singapore Dollar"),
        ("HKD", "Hong Kong Dollar"),
        ("NOK", "Norwegian Krone"),
        ("KRW", "South Korean Won"),
        ("INR", "Indian Rupee"),
        ("BRL", "Brazilian Real"),
        ("ZAR", "South African Rand"),
        ("DKK", "Danish Krone"),
        ("PLN", "Polish Zloty"),
    ]

    static let allCurrencies: [(code: String, name: String)] = {
        let locales = Locale.availableIdentifiers.map { Locale(identifier: $0) }
        var seen = Set<String>()
        var result: [(code: String, name: String)] = []
        for locale in locales {
            guard let code = locale.currency?.identifier else { continue }
            guard !seen.contains(code) else { continue }
            seen.insert(code)
            let name = Locale.current.localizedString(forCurrencyCode: code) ?? code
            result.append((code, name))
        }
        return result.sorted { $0.code < $1.code }
    }()
}
