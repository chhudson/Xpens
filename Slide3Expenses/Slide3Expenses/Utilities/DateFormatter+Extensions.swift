import Foundation

extension Date {

    /// Formats as "Jan 15, 2025"
    var displayString: String {
        formatted(.dateTime.month(.abbreviated).day().year())
    }

    /// Formats as "January 2025" for section headers
    var sectionHeader: String {
        formatted(.dateTime.month(.wide).year())
    }
}
