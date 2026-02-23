import SwiftUI
import SwiftData

@main
struct Slide3ExpensesApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Expense.self)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Text("Slide3 Expenses")
                .font(.largeTitle)
                .navigationTitle("Expenses")
        }
    }
}
