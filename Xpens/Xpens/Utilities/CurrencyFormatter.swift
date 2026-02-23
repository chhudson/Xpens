import Foundation

enum CurrencyFormatter {

    nonisolated(unsafe) private static var formatter: NumberFormatter = makeFormatter(code: "USD")

    private static func makeFormatter(code: String) -> NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = code
        return f
    }

    static func setCurrency(code: String) {
        formatter = makeFormatter(code: code)
    }

    static var currencyCode: String {
        formatter.currencyCode ?? "USD"
    }

    static func string(from amount: Decimal) -> String {
        formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    static func decimal(from string: String) -> Decimal? {
        let symbol = formatter.currencySymbol ?? "$"
        let grouping = formatter.groupingSeparator ?? ","
        let cleaned = string
            .replacingOccurrences(of: symbol, with: "")
            .replacingOccurrences(of: grouping, with: "")
            .trimmingCharacters(in: .whitespaces)
        return Decimal(string: cleaned)
    }
}
