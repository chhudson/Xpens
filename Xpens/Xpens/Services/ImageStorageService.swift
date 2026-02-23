import UIKit

enum ImageStorageService {

    private static let subdirectory = "Receipts"

    private static var receiptsDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appending(path: subdirectory, directoryHint: .isDirectory)
    }

    // MARK: - Save

    static func save(_ image: UIImage) throws -> String {
        let directory = receiptsDirectory
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let filename = "\(UUID().uuidString).jpg"
        let fileURL = directory.appending(path: filename)

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.compressionFailed
        }
        try data.write(to: fileURL, options: .atomic)

        return "\(subdirectory)/\(filename)"
    }

    // MARK: - Load

    static func loadImage(relativePath: String) -> UIImage? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appending(path: relativePath)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    // MARK: - Delete

    static func deleteImage(relativePath: String) throws {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appending(path: relativePath)
        try FileManager.default.removeItem(at: fileURL)
    }

    enum StorageError: LocalizedError {
        case compressionFailed

        var errorDescription: String? {
            switch self {
            case .compressionFailed:
                return "Failed to compress image to JPEG."
            }
        }
    }
}
