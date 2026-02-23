import Foundation
import Testing
@testable import Slide3Expenses

@Suite("CurrencyFormatter")
struct CurrencyFormatterTests {

    @Test("formats positive amounts as USD")
    func formatsPositiveAmounts() {
        #expect(CurrencyFormatter.string(from: 1234.56) == "$1,234.56")
        #expect(CurrencyFormatter.string(from: 0) == "$0.00")
        #expect(CurrencyFormatter.string(from: 99.90) == "$99.90")
    }

    @Test("formats negative amounts")
    func formatsNegativeAmounts() {
        let result = CurrencyFormatter.string(from: -50.00)
        #expect(result.contains("50.00"))
    }

    @Test("parses plain decimal strings")
    func parsesPlainDecimals() {
        #expect(CurrencyFormatter.decimal(from: "123.45") == Decimal(string: "123.45"))
        #expect(CurrencyFormatter.decimal(from: "0.99") == Decimal(string: "0.99"))
    }

    @Test("parses strings with dollar sign")
    func parsesDollarSign() {
        #expect(CurrencyFormatter.decimal(from: "$50.00") == Decimal(string: "50.00"))
    }

    @Test("parses strings with commas")
    func parsesCommas() {
        #expect(CurrencyFormatter.decimal(from: "$1,234.56") == Decimal(string: "1234.56"))
        #expect(CurrencyFormatter.decimal(from: "1,000") == Decimal(string: "1000"))
    }

    @Test("parses strings with whitespace")
    func parsesWhitespace() {
        #expect(CurrencyFormatter.decimal(from: "  42.00  ") == Decimal(string: "42.00"))
    }

    @Test("returns nil for non-numeric input")
    func returnsNilForInvalid() {
        #expect(CurrencyFormatter.decimal(from: "abc") == nil)
        #expect(CurrencyFormatter.decimal(from: "") == nil)
    }
}
