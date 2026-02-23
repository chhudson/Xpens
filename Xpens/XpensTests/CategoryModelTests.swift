import Foundation
import Testing
@testable import Xpens

@Suite("Category Model")
struct CategoryModelTests {

    @Test("initializes with all required fields")
    func initFields() {
        let cat = Category(name: "Food", icon: "fork.knife", color: "#4CAF50", sortOrder: 0)
        #expect(cat.name == "Food")
        #expect(cat.icon == "fork.knife")
        #expect(cat.color == "#4CAF50")
        #expect(cat.sortOrder == 0)
        #expect(cat.isDefault == false)
    }

    @Test("default categories factory creates 8 categories")
    func defaultCategories() {
        let defaults = Category.createDefaults()
        #expect(defaults.count == 8)
        #expect(defaults.allSatisfy { $0.isDefault })
    }

    @Test("default categories have unique sort orders")
    func uniqueSortOrders() {
        let defaults = Category.createDefaults()
        let orders = Set(defaults.map { $0.sortOrder })
        #expect(orders.count == defaults.count)
    }

    @Test("default categories have unique names")
    func uniqueNames() {
        let defaults = Category.createDefaults()
        let names = Set(defaults.map { $0.name })
        #expect(names.count == defaults.count)
    }

    @Test("swiftUIColor converts hex without crashing")
    func hexToColor() {
        let cat = Category(name: "Test", icon: "star", color: "#FF0000", sortOrder: 0)
        let _ = cat.swiftUIColor
    }

    @Test("each instance gets a unique UUID")
    func uniqueIds() {
        let a = Category(name: "A", icon: "star", color: "#000000", sortOrder: 0)
        let b = Category(name: "B", icon: "star", color: "#000000", sortOrder: 1)
        #expect(a.id != b.id)
    }
}
