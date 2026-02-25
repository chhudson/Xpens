import Testing
import Foundation
@testable import Xpens

private typealias ExpenseCategory = Xpens.Category

@Suite("Generate Sample Report", .serialized)
struct GenerateSampleReportTest {

    @Test("generate rich sample PDF for App Store screenshot")
    func generateSampleReport() throws {
        let cal = Calendar.current
        let now = Date.now
        func date(_ daysAgo: Int) -> Date {
            cal.date(byAdding: .day, value: -daysAgo, to: now) ?? now
        }

        // Categories
        let airline = ExpenseCategory(name: "Airline Tickets", icon: "airplane", color: "#2196F3", sortOrder: 0)
        let hotel = ExpenseCategory(name: "Hotel", icon: "building.2", color: "#9C27B0", sortOrder: 1)
        let rideshare = ExpenseCategory(name: "Rideshare", icon: "car", color: "#FF9800", sortOrder: 2)
        let food = ExpenseCategory(name: "Food", icon: "fork.knife", color: "#4CAF50", sortOrder: 3)
        let office = ExpenseCategory(name: "Office Supplies", icon: "pencil.and.ruler", color: "#607D8B", sortOrder: 4)
        let parking = ExpenseCategory(name: "Parking", icon: "parkingsign", color: "#795548", sortOrder: 5)
        let entertainment = ExpenseCategory(name: "Entertainment", icon: "film", color: "#E91E63", sortOrder: 6)

        // Tags
        let taxDeductible = Tag(name: "tax-deductible", color: "#2196F3")
        let q1 = Tag(name: "Q1-2026", color: "#4CAF50")
        let acme = Tag(name: "client: Acme", color: "#FF9800")

        // Sample expenses
        let expenses = [
            Expense(date: date(1),  category: airline, tags: [taxDeductible, acme], amount: 487.50, merchant: "Delta Airlines", client: "Acme Corp"),
            Expense(date: date(14), category: airline, tags: [taxDeductible], amount: 312.00, merchant: "United Airlines", client: "TechStart"),
            Expense(date: date(2),  category: hotel, tags: [taxDeductible, acme], amount: 219.00, merchant: "Marriott Downtown", client: "Acme Corp"),
            Expense(date: date(3),  category: hotel, tags: [taxDeductible, acme], amount: 219.00, merchant: "Marriott Downtown", client: "Acme Corp"),
            Expense(date: date(4),  category: hotel, tags: [taxDeductible, acme], amount: 219.00, merchant: "Marriott Downtown", client: "Acme Corp"),
            Expense(date: date(12), category: hotel, tags: [taxDeductible], amount: 189.00, merchant: "Hilton Garden Inn", client: "TechStart"),
            Expense(date: date(1),  category: rideshare, tags: [acme], amount: 34.75, merchant: "Uber to Airport", client: "Acme Corp"),
            Expense(date: date(2),  category: rideshare, tags: [acme], amount: 28.50, merchant: "Lyft to Hotel", client: "Acme Corp"),
            Expense(date: date(13), category: rideshare, amount: 42.00, merchant: "Uber to Convention Ctr", client: "TechStart"),
            Expense(date: date(0),  category: food, tags: [q1], amount: 6.25, merchant: "Blue Bottle Coffee"),
            Expense(date: date(1),  category: food, tags: [q1], amount: 14.85, merchant: "Chipotle", notes: "Lunch"),
            Expense(date: date(3),  category: food, tags: [taxDeductible, q1, acme], amount: 87.40, merchant: "The Capital Grille", client: "Acme Corp", notes: "Client dinner"),
            Expense(date: date(5),  category: food, tags: [q1], amount: 16.50, merchant: "Sweetgreen", notes: "Lunch"),
            Expense(date: date(7),  category: food, amount: 5.75, merchant: "Starbucks"),
            Expense(date: date(10), category: food, tags: [q1], amount: 22.00, merchant: "Shake Shack", notes: "Lunch"),
            Expense(date: date(1),  category: parking, tags: [taxDeductible], amount: 45.00, merchant: "Airport Parking"),
            Expense(date: date(4),  category: office, tags: [taxDeductible], amount: 32.60, merchant: "Staples", notes: "Printer paper & pens"),
            Expense(date: date(6),  category: entertainment, amount: 125.00, merchant: "Broadway Show", notes: "Team outing"),
            Expense(date: date(9),  category: office, tags: [taxDeductible], amount: 89.99, merchant: "Amazon", notes: "USB-C hub & cables"),
        ]

        let startDate = date(14)
        let endDate = now

        let url = try PDFExportService.exportToFile(
            expenses: expenses,
            startDate: startDate,
            endDate: endDate
        )

        // Copy to Desktop for screenshot use
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let dest = desktop
            .appendingPathComponent("XpensScreenshots")
            .appendingPathComponent("SampleReport.pdf")
        try? FileManager.default.createDirectory(
            at: dest.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? FileManager.default.removeItem(at: dest)
        try FileManager.default.copyItem(at: url, to: dest)
        try? FileManager.default.removeItem(at: url)

        #expect(FileManager.default.fileExists(atPath: dest.path()))
    }
}
