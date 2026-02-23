import Foundation
import Testing
@testable import Xpens

@Suite("Tag Model")
struct TagModelTests {

    @Test("initializes with name and color")
    func initFields() {
        let tag = Tag(name: "tax-deductible", color: "#4CAF50")
        #expect(tag.name == "tax-deductible")
        #expect(tag.color == "#4CAF50")
    }

    @Test("each instance gets a unique UUID")
    func uniqueIds() {
        let a = Tag(name: "a", color: "#000000")
        let b = Tag(name: "b", color: "#FFFFFF")
        #expect(a.id != b.id)
    }

    @Test("swiftUIColor converts hex without crashing")
    func hexToColor() {
        let tag = Tag(name: "test", color: "#FF5722")
        let _ = tag.swiftUIColor
    }
}
