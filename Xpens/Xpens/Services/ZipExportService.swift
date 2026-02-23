import Foundation
import ZIPFoundation

enum ZipExportService {

    // MARK: - Types

    enum ReportFormat: String, Hashable, CaseIterable {
        case pdf = "PDF"
        case csv = "CSV"
    }

    enum ZipExportError: LocalizedError {
        case stagingDirectoryCreationFailed
        case zipCreationFailed

        var errorDescription: String? {
            switch self {
            case .stagingDirectoryCreationFailed:
                return "Failed to create staging directory for zip export."
            case .zipCreationFailed:
                return "Failed to create zip archive."
            }
        }
    }

    // MARK: - Public API

    /// Bundles a report (PDF or CSV) and any receipt images into a zip file.
    /// Only receipts belonging to the provided expenses are included.
    static func exportToFile(
        expenses: [Expense],
        startDate: Date,
        endDate: Date,
        format: ReportFormat
    ) throws -> URL {
        let fm = FileManager.default
        let timestamp = fileTimestamp()
        let stagingName = "Xpens_Report_\(timestamp)"
        let stagingDir = fm.temporaryDirectory.appendingPathComponent(stagingName)
        let zipURL = fm.temporaryDirectory.appendingPathComponent("\(stagingName).zip")

        // Clean up staging dir when done (zip file persists for sharing)
        defer { try? fm.removeItem(at: stagingDir) }

        do {
            try fm.createDirectory(at: stagingDir, withIntermediateDirectories: true)
        } catch {
            throw ZipExportError.stagingDirectoryCreationFailed
        }

        // 1. Generate report into staging directory
        let reportURL: URL
        switch format {
        case .pdf:
            let tempPDF = try PDFExportService.exportToFile(
                expenses: expenses,
                startDate: startDate,
                endDate: endDate
            )
            let dest = stagingDir.appendingPathComponent(tempPDF.lastPathComponent)
            try fm.moveItem(at: tempPDF, to: dest)
            reportURL = dest

        case .csv:
            let tempCSV = try CSVExportService.exportToFile(expenses: expenses)
            let dest = stagingDir.appendingPathComponent(tempCSV.lastPathComponent)
            try fm.moveItem(at: tempCSV, to: dest)
            reportURL = dest
        }
        _ = reportURL // suppress unused warning

        // 2. Copy receipt images for these expenses only
        let receiptPaths = expenses.compactMap(\.receiptImagePath)
        if !receiptPaths.isEmpty {
            let receiptsDir = stagingDir.appendingPathComponent("Receipts")
            try fm.createDirectory(at: receiptsDir, withIntermediateDirectories: true)

            let docsDir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
            for relativePath in receiptPaths {
                let source = docsDir.appendingPathComponent(relativePath)
                guard fm.fileExists(atPath: source.path) else { continue }
                let filename = source.lastPathComponent
                let dest = receiptsDir.appendingPathComponent(filename)
                try fm.copyItem(at: source, to: dest)
            }
        }

        // 3. Create zip archive
        // Remove existing zip if present (e.g., from a previous export in the same second)
        if fm.fileExists(atPath: zipURL.path) {
            try fm.removeItem(at: zipURL)
        }
        try fm.zipItem(at: stagingDir, to: zipURL)

        return zipURL
    }

    // MARK: - Helpers

    private static func fileTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: Date())
    }
}
