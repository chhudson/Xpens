import Foundation
import Testing
@testable import Xpens

@Suite("UserPreferences")
struct UserPreferencesTests {

    @Test("defaults to USD currency")
    func defaultCurrency() {
        let prefs = UserPreferences()
        #expect(prefs.currencyCode == "USD")
    }

    @Test("defaults to not onboarded")
    func defaultOnboarding() {
        let prefs = UserPreferences()
        #expect(prefs.hasCompletedOnboarding == false)
    }

    @Test("starts with empty featured category IDs")
    func emptyFeatured() {
        let prefs = UserPreferences()
        #expect(prefs.featuredCategoryIDs.isEmpty)
    }

    @Test("no last recurring generation date by default")
    func noLastGeneration() {
        let prefs = UserPreferences()
        #expect(prefs.lastRecurringGenerationDate == nil)
    }

    @Test("stores custom currency code")
    func customCurrency() {
        let prefs = UserPreferences(currencyCode: "EUR")
        #expect(prefs.currencyCode == "EUR")
    }

    @Test("stores featured category IDs")
    func featuredCategories() {
        let ids = [UUID(), UUID(), UUID(), UUID()]
        let prefs = UserPreferences(featuredCategoryIDs: ids)
        #expect(prefs.featuredCategoryIDs.count == 4)
        #expect(prefs.featuredCategoryIDs == ids)
    }
}
