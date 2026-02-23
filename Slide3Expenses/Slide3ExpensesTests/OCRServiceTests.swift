import Foundation
import Testing
@testable import Slide3Expenses

@Suite("OCRService")
@MainActor
struct OCRServiceTests {

    private var sut: OCRService { OCRService.shared }

    // MARK: - Amount Extraction

    @Suite("Amount Extraction")
    @MainActor
    struct AmountExtraction {
        private var sut: OCRService { OCRService.shared }

        @Test("extracts labeled total")
        func labeledTotal() {
            let text = "Items: 3\nTax: $1.00\nTotal: $13.00"
            let amount = sut.extractAmount(from: text)
            #expect(amount == Decimal(string: "13.00"))
        }

        @Test("matches Subtotal when it appears (contains 'total')")
        func subtotalMatch() {
            let text = "Subtotal: $12.00\nTax: $1.00"
            let amount = sut.extractAmount(from: text)
            #expect(amount == Decimal(string: "12.00"))
        }

        @Test("extracts amount with 'Amount' label")
        func amountLabel() {
            let text = "Invoice #123\nAmount: $250.75"
            let amount = sut.extractAmount(from: text)
            #expect(amount == Decimal(string: "250.75"))
        }

        @Test("extracts amount with 'Due' label")
        func dueLabel() {
            let text = "Balance Due: $99.99"
            let amount = sut.extractAmount(from: text)
            #expect(amount == Decimal(string: "99.99"))
        }

        @Test("extracts amount with 'Sum' label")
        func sumLabel() {
            let text = "Sum: 45.50"
            let amount = sut.extractAmount(from: text)
            #expect(amount == Decimal(string: "45.50"))
        }

        @Test("extracts dollar sign amount when no label present")
        func dollarSignOnly() {
            let text = "Coffee Shop\n$4.50\nThank you!"
            let amount = sut.extractAmount(from: text)
            #expect(amount == Decimal(string: "4.50"))
        }

        @Test("extracts amount with comma thousands separator")
        func thousandsSeparator() {
            let text = "Total: $1,234.56"
            let amount = sut.extractAmount(from: text)
            #expect(amount == Decimal(string: "1234.56"))
        }

        @Test("prefers labeled amount over bare dollar amount")
        func prefersLabeledAmount() {
            let text = "$5.00 tip\nTotal: $25.00"
            let amount = sut.extractAmount(from: text)
            #expect(amount == Decimal(string: "25.00"))
        }

        @Test("returns nil for text with no amounts")
        func noAmounts() {
            let text = "Thank you for visiting!\nSee you again."
            let amount = sut.extractAmount(from: text)
            #expect(amount == nil)
        }

        @Test("handles label with colon and spaces")
        func labelWithSpaces() {
            let text = "Total :  $ 75.00"
            let amount = sut.extractAmount(from: text)
            #expect(amount == Decimal(string: "75.00"))
        }

        @Test("case insensitive label matching")
        func caseInsensitive() {
            let text = "TOTAL: $50.00"
            let amount = sut.extractAmount(from: text)
            #expect(amount == Decimal(string: "50.00"))
        }
    }

    // MARK: - Date Extraction

    @Suite("Date Extraction")
    @MainActor
    struct DateExtraction {
        private var sut: OCRService { OCRService.shared }

        @Test("extracts US-format date")
        func usFormat() {
            let text = "Date: 01/15/2025\nTotal: $50.00"
            let date = sut.extractDate(from: text)
            #expect(date != nil)
            if let date {
                let calendar = Calendar.current
                #expect(calendar.component(.month, from: date) == 1)
                #expect(calendar.component(.day, from: date) == 15)
                #expect(calendar.component(.year, from: date) == 2025)
            }
        }

        @Test("extracts written-out date")
        func writtenDate() {
            let text = "January 15, 2025\nReceipt"
            let date = sut.extractDate(from: text)
            #expect(date != nil)
        }

        @Test("returns nil when no date present")
        func noDate() {
            let text = "Coffee Shop\nTotal: $5.00\nThank you!"
            let date = sut.extractDate(from: text)
            #expect(date == nil)
        }
    }

    // MARK: - Merchant Extraction

    @Suite("Merchant Extraction")
    @MainActor
    struct MerchantExtraction {
        private var sut: OCRService { OCRService.shared }

        @Test("returns first non-empty line")
        func firstLine() {
            let lines = ["Starbucks", "123 Main St", "Total: $5.00"]
            let merchant = sut.extractMerchant(from: lines)
            #expect(merchant == "Starbucks")
        }

        @Test("skips blank lines")
        func skipsBlankLines() {
            let lines = ["   ", "", "Hilton Hotel", "Room 205"]
            let merchant = sut.extractMerchant(from: lines)
            #expect(merchant == "Hilton Hotel")
        }

        @Test("returns nil for all-empty lines")
        func allEmpty() {
            let lines = ["", "   ", "  "]
            let merchant = sut.extractMerchant(from: lines)
            #expect(merchant == nil)
        }

        @Test("returns nil for empty array")
        func emptyArray() {
            let merchant = sut.extractMerchant(from: [])
            #expect(merchant == nil)
        }
    }
}
