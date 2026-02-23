import Foundation
import SwiftData

@Model
final class UserPreferences {
    var id: UUID
    var currencyCode: String
    var hasCompletedOnboarding: Bool
    var featuredCategoryIDs: [UUID]
    var lastRecurringGenerationDate: Date?

    init(
        id: UUID = UUID(),
        currencyCode: String = "USD",
        hasCompletedOnboarding: Bool = false,
        featuredCategoryIDs: [UUID] = []
    ) {
        self.id = id
        self.currencyCode = currencyCode
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.featuredCategoryIDs = featuredCategoryIDs
    }
}
