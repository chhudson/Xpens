import Foundation
import Testing
@testable import Xpens

private typealias ExpenseCategory = Xpens.Category

@Suite("PDFExportService", .serialized)
struct PDFExportServiceTests {

    private let startDate = Date(timeIntervalSince1970: 1_704_067_200) // 2024-01-01
    private let endDate = Date(timeIntervalSince1970: 1_706_745_600)   // 2024-01-31

    private func makeCategory(name: String, icon: String, color: String, sortOrder: Int) -> ExpenseCategory {
        ExpenseCategory(name: name, icon: icon, color: color, sortOrder: sortOrder)
    }

    // MARK: - File Output

    @Test("export creates a file on disk")
    func createsFile() throws {
        let food = makeCategory(name: "Food", icon: "fork.knife", color: "#4CAF50", sortOrder: 3)
        let expenses = [
            Expense(category: food, amount: 15.00, merchant: "Chipotle", client: "Acme")
        ]
        let url = try PDFExportService.exportToFile(
            expenses: expenses, startDate: startDate, endDate: endDate
        )
        #expect(FileManager.default.fileExists(atPath: url.path()))
        try? FileManager.default.removeItem(at: url)
    }

    @Test("exported file starts with PDF magic bytes")
    func pdfMagicBytes() throws {
        let hotel = makeCategory(name: "Hotel", icon: "building.2", color: "#9C27B0", sortOrder: 1)
        let expenses = [
            Expense(category: hotel, amount: 200.00, merchant: "Hilton")
        ]
        let url = try PDFExportService.exportToFile(
            expenses: expenses, startDate: startDate, endDate: endDate
        )
        let data = try Data(contentsOf: url)
        // PDF files start with %PDF
        #expect(data.count >= 4)
        let header = String(data: data.prefix(4), encoding: .ascii)
        #expect(header == "%PDF")
        try? FileManager.default.removeItem(at: url)
    }

    @Test("exported filename contains 'Xpens_Report'")
    func filenameFormat() throws {
        let url = try PDFExportService.exportToFile(
            expenses: [], startDate: startDate, endDate: endDate
        )
        #expect(url.lastPathComponent.hasPrefix("Xpens_Report_"))
        #expect(url.pathExtension == "pdf")
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Content

    @Test("PDF with no expenses still produces a valid file")
    func emptyExpenses() throws {
        let url = try PDFExportService.exportToFile(
            expenses: [], startDate: startDate, endDate: endDate
        )
        #expect(FileManager.default.fileExists(atPath: url.path()))
        try? FileManager.default.removeItem(at: url)
    }

    @Test("PDF with multiple categories produces a file")
    func multipleCategories() throws {
        let airline = makeCategory(name: "Airline Tickets", icon: "airplane", color: "#2196F3", sortOrder: 0)
        let hotel = makeCategory(name: "Hotel", icon: "building.2", color: "#9C27B0", sortOrder: 1)
        let rideshare = makeCategory(name: "Rideshare", icon: "car", color: "#FF9800", sortOrder: 2)
        let food = makeCategory(name: "Food", icon: "fork.knife", color: "#4CAF50", sortOrder: 3)
        let expenses = [
            Expense(category: airline, amount: 450.00, merchant: "Delta"),
            Expense(category: hotel, amount: 200.00, merchant: "Marriott"),
            Expense(category: rideshare, amount: 35.00, merchant: "Uber"),
            Expense(category: food, amount: 22.50, merchant: "Panera"),
        ]
        let url = try PDFExportService.exportToFile(
            expenses: expenses, startDate: startDate, endDate: endDate
        )
        let data = try Data(contentsOf: url)
        #expect(data.count > 500) // reasonable size for a multi-row PDF
        try? FileManager.default.removeItem(at: url)
    }

    @Test("many expenses produce a multi-page PDF")
    func multiPagePDF() throws {
        let categories = Xpens.Category.createDefaults()
        // ~50 rows across multiple categories should force page breaks
        let expenses = (0..<50).map { i in
            Expense(
                category: categories[i % categories.count],
                amount: Decimal(10 + i),
                merchant: "Merchant \(i)"
            )
        }
        let url = try PDFExportService.exportToFile(
            expenses: expenses, startDate: startDate, endDate: endDate
        )
        let data = try Data(contentsOf: url)
        // A multi-page PDF should be substantially larger than a single-page one
        #expect(data.count > 5000)
        try? FileManager.default.removeItem(at: url)
    }
}
