import Foundation
import Testing
import ZIPFoundation
@testable import Xpens

private typealias ExpenseCategory = Xpens.Category

@Suite("ZipExportService", .serialized)
struct ZipExportServiceTests {

    private let startDate = Date(timeIntervalSince1970: 1_704_067_200) // 2024-01-01
    private let endDate = Date(timeIntervalSince1970: 1_706_745_600)   // 2024-01-31

    private func makeCategory() -> ExpenseCategory {
        ExpenseCategory(name: "Food", icon: "fork.knife", color: "#4CAF50", sortOrder: 3)
    }

    /// Creates a dummy JPEG file in Documents/Receipts/ and returns the relative path.
    private func createDummyReceipt(filename: String = "\(UUID().uuidString).jpg") throws -> String {
        let fm = FileManager.default
        let docsDir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let receiptsDir = docsDir.appendingPathComponent("Receipts")
        try fm.createDirectory(at: receiptsDir, withIntermediateDirectories: true)

        let fileURL = receiptsDir.appendingPathComponent(filename)
        // Minimal valid JPEG: just enough bytes to be a file
        let dummyData = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10] + Array(repeating: UInt8(0), count: 50))
        try dummyData.write(to: fileURL)

        return "Receipts/\(filename)"
    }

    private func removeDummyReceipt(_ relativePath: String) {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try? FileManager.default.removeItem(at: docsDir.appendingPathComponent(relativePath))
    }

    // MARK: - PDF Format

    @Test("PDF format creates a valid zip file")
    func pdfFormatCreatesZip() throws {
        let expenses = [Expense(category: makeCategory(), amount: 25.00, merchant: "Cafe")]
        let url = try ZipExportService.exportToFile(
            expenses: expenses, startDate: startDate, endDate: endDate, format: .pdf
        )
        #expect(FileManager.default.fileExists(atPath: url.path()))
        // Verify it's a valid zip (ZIP magic bytes: PK\x03\x04)
        let data = try Data(contentsOf: url)
        #expect(data.count >= 4)
        #expect(data[0] == 0x50) // P
        #expect(data[1] == 0x4B) // K
        try? FileManager.default.removeItem(at: url)
    }

    @Test("zip contains a PDF file when format is PDF")
    func zipContainsPDF() throws {
        let expenses = [Expense(category: makeCategory(), amount: 10.00, merchant: "Deli")]
        let url = try ZipExportService.exportToFile(
            expenses: expenses, startDate: startDate, endDate: endDate, format: .pdf
        )
        let archive = try Archive(url: url, accessMode: .read)
        let pdfEntries = archive.filter { $0.path.hasSuffix(".pdf") }
        #expect(pdfEntries.count == 1)
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - CSV Format

    @Test("CSV format creates a valid zip with CSV inside")
    func csvFormatCreatesZip() throws {
        let expenses = [Expense(category: makeCategory(), amount: 42.00, merchant: "Store")]
        let url = try ZipExportService.exportToFile(
            expenses: expenses, startDate: startDate, endDate: endDate, format: .csv
        )
        let archive = try Archive(url: url, accessMode: .read)
        let csvEntries = archive.filter { $0.path.hasSuffix(".csv") }
        #expect(csvEntries.count == 1)
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Empty Expenses

    @Test("empty expenses still produces a valid zip")
    func emptyExpenses() throws {
        let url = try ZipExportService.exportToFile(
            expenses: [], startDate: startDate, endDate: endDate, format: .pdf
        )
        #expect(FileManager.default.fileExists(atPath: url.path()))
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Receipts

    @Test("no Receipts folder when no expenses have receipt images")
    func noReceiptsFolderWhenNoReceipts() throws {
        let expenses = [Expense(category: makeCategory(), amount: 5.00, merchant: "Snack")]
        let url = try ZipExportService.exportToFile(
            expenses: expenses, startDate: startDate, endDate: endDate, format: .pdf
        )
        let archive = try Archive(url: url, accessMode: .read)
        let receiptEntries = archive.filter { $0.path.contains("Receipts") }
        #expect(receiptEntries.isEmpty)
        try? FileManager.default.removeItem(at: url)
    }

    @Test("Receipts folder present when expenses have receipt images")
    func receiptsFolderPresent() throws {
        let receiptPath = try createDummyReceipt()
        defer { removeDummyReceipt(receiptPath) }

        let expense = Expense(
            category: makeCategory(),
            amount: 99.00,
            merchant: "Restaurant",
            receiptImagePath: receiptPath
        )
        let url = try ZipExportService.exportToFile(
            expenses: [expense], startDate: startDate, endDate: endDate, format: .pdf
        )
        let archive = try Archive(url: url, accessMode: .read)
        let receiptEntries = archive.filter {
            $0.path.contains("Receipts/") && $0.path.hasSuffix(".jpg")
        }
        #expect(receiptEntries.count == 1)
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Filename

    @Test("filename follows Xpens_Report_*.zip format")
    func filenameFormat() throws {
        let url = try ZipExportService.exportToFile(
            expenses: [], startDate: startDate, endDate: endDate, format: .csv
        )
        #expect(url.lastPathComponent.hasPrefix("Xpens_Report_"))
        #expect(url.pathExtension == "zip")
        try? FileManager.default.removeItem(at: url)
    }
}
