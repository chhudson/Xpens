import Foundation

enum CSVExportService {

    /// Generates an RFC 4180 compliant CSV string from an array of expenses.
    static func generateCSV(from expenses: [Expense]) -> String {
        let header = "Date,Category,Merchant,Client,Amount,Notes,Tags"
        let rows = expenses.map { expense in
            let date = expense.date.formatted(.iso8601.year().month().day())
            let amount = "\(expense.amount)"
            let tags = (expense.tags ?? []).map(\.name).joined(separator: ", ")
            return [
                date,
                expense.category?.name ?? "Uncategorized",
                expense.merchant,
                expense.client,
                amount,
                expense.notes,
                tags
            ]
            .map { escapeField($0) }
            .joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\r\n")
    }

    /// Writes CSV to a temporary file with UTF-8 BOM for Excel compatibility.
    /// Returns the file URL on success.
    static func exportToFile(expenses: [Expense]) throws -> URL {
        let csv = generateCSV(from: expenses)
        let bom = "\u{FEFF}"
        let content = bom + csv

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "Xpens_Expenses_\(fileTimestamp()).csv"
            )
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - Private Helpers

    /// Escapes a CSV field per RFC 4180.
    /// Fields containing commas, quotes, or newlines are wrapped in quotes.
    /// Existing quotes are doubled.
    private static func escapeField(_ field: String) -> String {
        let needsQuoting = field.contains(",")
            || field.contains("\"")
            || field.contains("\n")
            || field.contains("\r")
        guard needsQuoting else { return field }
        let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    private static func fileTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: Date())
    }
}
