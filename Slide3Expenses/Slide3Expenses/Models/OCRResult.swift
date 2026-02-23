import Foundation

struct OCRResult: Sendable {
    let recognizedText: String
    let confidence: Double
    let extractedAmount: Decimal?
    let extractedDate: Date?
    let extractedMerchant: String?
}
