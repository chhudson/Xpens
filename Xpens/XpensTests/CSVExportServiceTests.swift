import Testing
import Foundation
@testable import Xpens

@Suite("CSVExportService")
struct CSVExportServiceTests {

    @Test("empty expense list produces header only")
    func emptyList() {
        let csv = CSVExportService.generateCSV(from: [])
        #expect(csv == "Date,Category,Merchant,Client,Amount,Notes")
    }

    @Test("single expense produces correct row")
    func singleExpense() {
        let expense = Expense(
            date: Date(timeIntervalSince1970: 1_700_000_000), // 2023-11-14
            category: .food,
            amount: 25.50,
            merchant: "Chipotle",
            client: "Personal",
            notes: "Lunch"
        )
        let csv = CSVExportService.generateCSV(from: [expense])
        let lines = csv.components(separatedBy: "\r\n")
        #expect(lines.count == 2)
        #expect(lines[0] == "Date,Category,Merchant,Client,Amount,Notes")
        #expect(lines[1].contains("Food"))
        #expect(lines[1].contains("Chipotle"))
        #expect(lines[1].contains("25.5"))
    }

    @Test("fields with commas are quoted")
    func commasInFields() {
        let expense = Expense(
            merchant: "Joe's Pizza, Inc.",
            notes: ""
        )
        let csv = CSVExportService.generateCSV(from: [expense])
        #expect(csv.contains("\"Joe's Pizza, Inc.\""))
    }

    @Test("fields with quotes are escaped")
    func quotesInFields() {
        let expense = Expense(
            merchant: "The \"Best\" Place",
            notes: ""
        )
        let csv = CSVExportService.generateCSV(from: [expense])
        #expect(csv.contains("\"The \"\"Best\"\" Place\""))
    }

    @Test("rows are separated by CRLF")
    func crlfSeparators() {
        let expenses = [Expense(), Expense()]
        let csv = CSVExportService.generateCSV(from: expenses)
        let crlfCount = csv.components(separatedBy: "\r\n").count - 1
        #expect(crlfCount == 2) // header + 2 rows = 2 separators
    }

    @Test("exportToFile writes file with UTF-8 BOM")
    func exportToFileWritesBOM() throws {
        let expense = Expense(amount: 10.00, merchant: "Test")
        let url = try CSVExportService.exportToFile(expenses: [expense])
        let data = try Data(contentsOf: url)
        // UTF-8 BOM bytes: EF BB BF
        #expect(data[0] == 0xEF)
        #expect(data[1] == 0xBB)
        #expect(data[2] == 0xBF)
        try? FileManager.default.removeItem(at: url)
    }
}
