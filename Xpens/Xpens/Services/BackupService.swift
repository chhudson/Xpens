import Foundation
import SwiftData

enum BackupService {

    // MARK: - DTOs

    struct BackupManifest: Codable {
        let version: Int
        let createdAt: Date
        let expenseCount: Int
        let categoryCount: Int
        let tagCount: Int
    }

    struct CategoryDTO: Codable {
        let id: UUID
        let name: String
        let icon: String
        let color: String
        let sortOrder: Int
        let isDefault: Bool
    }

    struct TagDTO: Codable {
        let id: UUID
        let name: String
        let color: String
    }

    struct ExpenseDTO: Codable {
        let id: UUID
        let date: Date
        let amount: String
        let merchant: String
        let client: String
        let notes: String
        let receiptImagePath: String?
        let createdAt: Date
        let isRecurring: Bool
        let recurrenceRule: String?
        let lastGeneratedDate: Date?
        let categoryID: UUID?
        let tagIDs: [UUID]
    }

    struct PreferencesDTO: Codable {
        let currencyCode: String
        let hasCompletedOnboarding: Bool
        let featuredCategoryIDs: [UUID]
    }

    // MARK: - BackupInfo

    struct BackupInfo: Identifiable, Sendable {
        let id: String
        let url: URL
        let date: Date
        let expenseCount: Int
        let size: Int64
    }

    // MARK: - Errors

    enum BackupError: LocalizedError {
        case directoryUnavailable
        case manifestNotFound
        case restoreFailed(String)

        var errorDescription: String? {
            switch self {
            case .directoryUnavailable:
                "Could not access backup directory."
            case .manifestNotFound:
                "Backup manifest not found."
            case .restoreFailed(let reason):
                "Restore failed: \(reason)"
            }
        }
    }

    // MARK: - Directory

    private static func backupsDirectory() -> URL {
        if let icloudURL = FileManager.default.url(
            forUbiquityContainerIdentifier: "iCloud.com.xpens.app"
        ) {
            let dir = icloudURL
                .appendingPathComponent("Documents")
                .appendingPathComponent("Backups")
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            return dir
        }
        let dir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Backups")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    // MARK: - Backup

    static func backup(modelContext: ModelContext) throws {
        let fm = FileManager.default
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        // Fetch all data
        let expenses = try modelContext.fetch(FetchDescriptor<Expense>())
        let categories = try modelContext.fetch(FetchDescriptor<Category>())
        let tags = try modelContext.fetch(FetchDescriptor<Tag>())
        let preferences = try modelContext.fetch(FetchDescriptor<UserPreferences>())

        // Create timestamped backup directory
        let timestamp = ISO8601DateFormatter().string(from: .now)
            .replacingOccurrences(of: ":", with: "-")
        let backupDir = backupsDirectory().appendingPathComponent("Xpens_\(timestamp)")
        try fm.createDirectory(at: backupDir, withIntermediateDirectories: true)

        // Convert to DTOs
        let categoryDTOs = categories.map {
            CategoryDTO(
                id: $0.id, name: $0.name, icon: $0.icon,
                color: $0.color, sortOrder: $0.sortOrder, isDefault: $0.isDefault
            )
        }
        let tagDTOs = tags.map { TagDTO(id: $0.id, name: $0.name, color: $0.color) }
        let expenseDTOs = expenses.map { expense in
            ExpenseDTO(
                id: expense.id,
                date: expense.date,
                amount: "\(expense.amount)",
                merchant: expense.merchant,
                client: expense.client,
                notes: expense.notes,
                receiptImagePath: expense.receiptImagePath,
                createdAt: expense.createdAt,
                isRecurring: expense.isRecurring,
                recurrenceRule: expense.recurrenceRule,
                lastGeneratedDate: expense.lastGeneratedDate,
                categoryID: expense.category?.id,
                tagIDs: expense.tags?.map(\.id) ?? []
            )
        }

        // Write JSON files
        try encoder.encode(categoryDTOs)
            .write(to: backupDir.appendingPathComponent("categories.json"))
        try encoder.encode(tagDTOs)
            .write(to: backupDir.appendingPathComponent("tags.json"))
        try encoder.encode(expenseDTOs)
            .write(to: backupDir.appendingPathComponent("expenses.json"))

        if let prefs = preferences.first {
            let dto = PreferencesDTO(
                currencyCode: prefs.currencyCode,
                hasCompletedOnboarding: prefs.hasCompletedOnboarding,
                featuredCategoryIDs: prefs.featuredCategoryIDs
            )
            try encoder.encode(dto)
                .write(to: backupDir.appendingPathComponent("preferences.json"))
        }

        // Write manifest
        let manifest = BackupManifest(
            version: 1,
            createdAt: .now,
            expenseCount: expenses.count,
            categoryCount: categories.count,
            tagCount: tags.count
        )
        try encoder.encode(manifest)
            .write(to: backupDir.appendingPathComponent("manifest.json"))

        // Copy receipt images
        let documentsDir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let receiptsBackupDir = backupDir.appendingPathComponent("Receipts")
        try fm.createDirectory(at: receiptsBackupDir, withIntermediateDirectories: true)

        for expense in expenses {
            guard let path = expense.receiptImagePath else { continue }
            let source = documentsDir.appendingPathComponent(path)
            let filename = URL(fileURLWithPath: path).lastPathComponent
            let dest = receiptsBackupDir.appendingPathComponent(filename)
            if fm.fileExists(atPath: source.path) {
                try? fm.copyItem(at: source, to: dest)
            }
        }
    }

    // MARK: - List Backups

    static func listBackups() -> [BackupInfo] {
        let fm = FileManager.default
        let dir = backupsDirectory()

        guard let contents = try? fm.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: nil
        ) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return contents.compactMap { url in
            let manifestURL = url.appendingPathComponent("manifest.json")
            guard let data = try? Data(contentsOf: manifestURL),
                  let manifest = try? decoder.decode(BackupManifest.self, from: data) else {
                return nil
            }
            return BackupInfo(
                id: url.lastPathComponent,
                url: url,
                date: manifest.createdAt,
                expenseCount: manifest.expenseCount,
                size: directorySize(url: url)
            )
        }
        .sorted { $0.date > $1.date }
    }

    // MARK: - Restore

    static func restore(from backup: BackupInfo, modelContext: ModelContext) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let fm = FileManager.default

        // Read backup data
        let categoryDTOs = try decoder.decode(
            [CategoryDTO].self,
            from: Data(contentsOf: backup.url.appendingPathComponent("categories.json"))
        )
        let tagDTOs = try decoder.decode(
            [TagDTO].self,
            from: Data(contentsOf: backup.url.appendingPathComponent("tags.json"))
        )
        let expenseDTOs = try decoder.decode(
            [ExpenseDTO].self,
            from: Data(contentsOf: backup.url.appendingPathComponent("expenses.json"))
        )
        let prefsDTO = try? decoder.decode(
            PreferencesDTO.self,
            from: Data(contentsOf: backup.url.appendingPathComponent("preferences.json"))
        )

        // Delete all existing data
        try modelContext.delete(model: Expense.self)
        try modelContext.delete(model: Category.self)
        try modelContext.delete(model: Tag.self)
        try modelContext.delete(model: UserPreferences.self)
        try modelContext.save()

        // Import categories first (expenses reference them)
        var categoryMap: [UUID: Category] = [:]
        for dto in categoryDTOs {
            let cat = Category(
                id: dto.id, name: dto.name, icon: dto.icon,
                color: dto.color, sortOrder: dto.sortOrder, isDefault: dto.isDefault
            )
            modelContext.insert(cat)
            categoryMap[dto.id] = cat
        }

        // Import tags
        var tagMap: [UUID: Tag] = [:]
        for dto in tagDTOs {
            let tag = Tag(id: dto.id, name: dto.name, color: dto.color)
            modelContext.insert(tag)
            tagMap[dto.id] = tag
        }

        // Import expenses (with relationship linking)
        for dto in expenseDTOs {
            let expense = Expense(
                id: dto.id,
                date: dto.date,
                category: dto.categoryID.flatMap { categoryMap[$0] },
                tags: dto.tagIDs.isEmpty ? nil : dto.tagIDs.compactMap { tagMap[$0] },
                amount: Decimal(string: dto.amount) ?? 0,
                merchant: dto.merchant,
                client: dto.client,
                notes: dto.notes,
                receiptImagePath: dto.receiptImagePath,
                createdAt: dto.createdAt,
                isRecurring: dto.isRecurring,
                recurrenceRule: dto.recurrenceRule,
                lastGeneratedDate: dto.lastGeneratedDate
            )
            modelContext.insert(expense)
        }

        // Import preferences
        if let prefsDTO {
            let prefs = UserPreferences(
                currencyCode: prefsDTO.currencyCode,
                hasCompletedOnboarding: prefsDTO.hasCompletedOnboarding,
                featuredCategoryIDs: prefsDTO.featuredCategoryIDs
            )
            modelContext.insert(prefs)
            CurrencyFormatter.setCurrency(code: prefsDTO.currencyCode)
        }

        try modelContext.save()

        // Copy receipt images back to Documents/Receipts/
        let documentsDir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let receiptsDir = documentsDir.appendingPathComponent("Receipts")
        try? fm.createDirectory(at: receiptsDir, withIntermediateDirectories: true)

        let receiptsBackupDir = backup.url.appendingPathComponent("Receipts")
        if let receiptFiles = try? fm.contentsOfDirectory(at: receiptsBackupDir, includingPropertiesForKeys: nil) {
            for file in receiptFiles {
                let dest = receiptsDir.appendingPathComponent(file.lastPathComponent)
                if fm.fileExists(atPath: dest.path) {
                    try? fm.removeItem(at: dest)
                }
                try? fm.copyItem(at: file, to: dest)
            }
        }
    }

    // MARK: - Delete

    static func deleteBackup(_ backup: BackupInfo) throws {
        try FileManager.default.removeItem(at: backup.url)
    }

    // MARK: - Helpers

    private static func directorySize(url: URL) -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: url, includingPropertiesForKeys: [.fileSizeKey]
        ) else { return 0 }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                total += Int64(size)
            }
        }
        return total
    }
}
