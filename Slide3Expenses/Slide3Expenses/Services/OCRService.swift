import Vision
import UIKit

@MainActor
final class OCRService {

    static let shared = OCRService()
    private init() {}

    func recognizeText(from image: UIImage) async throws -> OCRResult {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        let observations = try await performRecognition(on: cgImage)
        return buildResult(from: observations)
    }

    // MARK: - Vision request

    private nonisolated func performRecognition(on cgImage: CGImage) async throws -> [VNRecognizedTextObservation] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                continuation.resume(returning: observations)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Parse results

    private nonisolated func buildResult(from observations: [VNRecognizedTextObservation]) -> OCRResult {
        let lines = observations.compactMap { $0.topCandidates(1).first }
        let fullText = lines.map(\.string).joined(separator: "\n")
        let avgConfidence = lines.isEmpty ? 0.0 : lines.map(\.confidence).reduce(0, +) / Float(lines.count)

        return OCRResult(
            recognizedText: fullText,
            confidence: Double(avgConfidence),
            extractedAmount: extractAmount(from: fullText),
            extractedDate: extractDate(from: fullText),
            extractedMerchant: extractMerchant(from: lines.map(\.string))
        )
    }

    // MARK: - Amount extraction

    nonisolated func extractAmount(from text: String) -> Decimal? {
        // Try labeled patterns first (Total, Amount, etc.)
        let patterns = [
            #"(?i)(?:total|amount|sum|due)\s*:?\s*\$?\s*(\d{1,}[,\d]*\.\d{2})"#,
            #"\$\s*(\d{1,}[,\d]*\.\d{2})"#
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range(at: 1), in: text) else { continue }
            let raw = String(text[range]).replacingOccurrences(of: ",", with: "")
            if let value = Decimal(string: raw) { return value }
        }
        return nil
    }

    // MARK: - Date extraction

    nonisolated func extractDate(from text: String) -> Date? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        return detector.firstMatch(in: text, range: range)?.date
    }

    // MARK: - Merchant extraction

    nonisolated func extractMerchant(from lines: [String]) -> String? {
        lines.first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    enum OCRError: LocalizedError {
        case invalidImage

        var errorDescription: String? {
            "Could not read the image for text recognition."
        }
    }
}
