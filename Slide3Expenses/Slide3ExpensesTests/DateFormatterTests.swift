import Testing
import Foundation
@testable import Slide3Expenses

@Suite("Date Extensions")
struct DateFormatterTests {

    // Use a fixed date: January 15, 2025 at noon UTC
    private var sampleDate: Date {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 12
        components.timeZone = TimeZone(identifier: "UTC")
        return Calendar.current.date(from: components)!
    }

    @Test("displayString contains abbreviated month, day, and year")
    func displayStringFormat() {
        let result = sampleDate.displayString
        #expect(result.contains("Jan"))
        #expect(result.contains("15"))
        #expect(result.contains("2025"))
    }

    @Test("sectionHeader contains full month name and year")
    func sectionHeaderFormat() {
        let result = sampleDate.sectionHeader
        #expect(result.contains("January"))
        #expect(result.contains("2025"))
    }
}
