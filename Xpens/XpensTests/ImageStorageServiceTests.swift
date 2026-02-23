import Foundation
import Testing
import UIKit
@testable import Xpens

@Suite("ImageStorageService")
struct ImageStorageServiceTests {

    /// Creates a small solid-color test image.
    private func makeTestImage() -> UIImage {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    /// Resolves a relative path against the documents directory.
    private func resolveURL(relativePath: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appending(path: relativePath)
    }

    // MARK: - Save

    @Test("save returns path in Receipts subdirectory with .jpg extension")
    func saveReturnsCorrectPath() throws {
        let image = makeTestImage()
        let path = try ImageStorageService.save(image)
        #expect(path.hasPrefix("Receipts/"))
        #expect(path.hasSuffix(".jpg"))
        // Cleanup
        try? FileManager.default.removeItem(at: resolveURL(relativePath: path))
    }

    @Test("save creates a file on disk")
    func saveCreatesFile() throws {
        let image = makeTestImage()
        let path = try ImageStorageService.save(image)
        let url = resolveURL(relativePath: path)
        #expect(FileManager.default.fileExists(atPath: url.path()))
        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    @Test("save produces unique paths for each call")
    func saveProducesUniquePaths() throws {
        let image = makeTestImage()
        let path1 = try ImageStorageService.save(image)
        let path2 = try ImageStorageService.save(image)
        #expect(path1 != path2)
        // Cleanup
        try? FileManager.default.removeItem(at: resolveURL(relativePath: path1))
        try? FileManager.default.removeItem(at: resolveURL(relativePath: path2))
    }

    // MARK: - Load

    @Test("load returns image for a saved path")
    func loadRoundTrip() throws {
        let image = makeTestImage()
        let path = try ImageStorageService.save(image)
        let loaded = ImageStorageService.loadImage(relativePath: path)
        #expect(loaded != nil)
        // Cleanup
        try? FileManager.default.removeItem(at: resolveURL(relativePath: path))
    }

    @Test("load returns nil for non-existent path")
    func loadNonExistent() {
        let loaded = ImageStorageService.loadImage(relativePath: "Receipts/does-not-exist.jpg")
        #expect(loaded == nil)
    }

    // MARK: - Delete

    @Test("delete removes the file from disk")
    func deleteRemovesFile() throws {
        let image = makeTestImage()
        let path = try ImageStorageService.save(image)
        let url = resolveURL(relativePath: path)

        try ImageStorageService.deleteImage(relativePath: path)
        #expect(!FileManager.default.fileExists(atPath: url.path()))
    }

    @Test("delete throws for non-existent path")
    func deleteThrowsForMissing() {
        #expect(throws: (any Error).self) {
            try ImageStorageService.deleteImage(relativePath: "Receipts/no-such-file.jpg")
        }
    }
}
