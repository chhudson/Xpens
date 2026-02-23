import SwiftUI

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case airlineTickets = "airline_tickets"
    case hotel = "hotel"
    case rideshare = "rideshare"
    case food = "food"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .airlineTickets: "Airline Tickets"
        case .hotel: "Hotel"
        case .rideshare: "Rideshare"
        case .food: "Food"
        }
    }

    var icon: String {
        switch self {
        case .airlineTickets: "airplane"
        case .hotel: "building.2"
        case .rideshare: "car"
        case .food: "fork.knife"
        }
    }

    var color: Color {
        switch self {
        case .airlineTickets: .blue
        case .hotel: .purple
        case .rideshare: .orange
        case .food: .green
        }
    }
}
