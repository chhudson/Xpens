import Foundation
import SwiftData
import SwiftUI

@Model
final class Category: Identifiable {
    var id: UUID
    var name: String
    var icon: String
    var color: String
    var sortOrder: Int
    var isDefault: Bool

    @Relationship(inverse: \Expense.category) var expenses: [Expense]?

    var swiftUIColor: Color {
        Color(hex: color)
    }

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        color: String,
        sortOrder: Int,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.sortOrder = sortOrder
        self.isDefault = isDefault
    }

    static func createDefaults() -> [Category] {
        [
            Category(name: "Airline Tickets", icon: "airplane", color: "#2196F3", sortOrder: 0, isDefault: true),
            Category(name: "Hotel", icon: "building.2", color: "#9C27B0", sortOrder: 1, isDefault: true),
            Category(name: "Rideshare", icon: "car", color: "#FF9800", sortOrder: 2, isDefault: true),
            Category(name: "Food", icon: "fork.knife", color: "#4CAF50", sortOrder: 3, isDefault: true),
            Category(name: "Office Supplies", icon: "pencil.and.ruler", color: "#607D8B", sortOrder: 4, isDefault: true),
            Category(name: "Parking", icon: "parkingsign", color: "#795548", sortOrder: 5, isDefault: true),
            Category(name: "Entertainment", icon: "film", color: "#E91E63", sortOrder: 6, isDefault: true),
            Category(name: "Misc", icon: "ellipsis.circle", color: "#9E9E9E", sortOrder: 7, isDefault: true),
        ]
    }
}
