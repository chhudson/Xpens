import SwiftUI

enum ExpenseSortOrder: String, CaseIterable, Identifiable {
    case dateDescending = "Newest First"
    case dateAscending = "Oldest First"
    case amountDescending = "Highest Amount"
    case amountAscending = "Lowest Amount"

    var id: String { rawValue }
}

struct ExpenseFilterView: View {
    @Binding var selectedCategory: ExpenseCategory?
    @Binding var selectedClient: String
    @Binding var sortOrder: ExpenseSortOrder
    @Environment(\.dismiss) private var dismiss

    let availableClients: [String]

    var body: some View {
        NavigationStack {
            Form {
                categorySection
                clientSection
                sortSection
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") { resetFilters() }
                }
            }
        }
    }

    private var categorySection: some View {
        Section("Category") {
            Button("All Categories") {
                selectedCategory = nil
            }
            .foregroundStyle(selectedCategory == nil ? .primary : .secondary)

            ForEach(ExpenseCategory.allCases) { cat in
                Button {
                    selectedCategory = cat
                } label: {
                    HStack {
                        Label(cat.displayName, systemImage: cat.icon)
                            .foregroundStyle(cat.color)
                        Spacer()
                        if selectedCategory == cat {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
    }

    private var clientSection: some View {
        Section("Client") {
            TextField("Filter by client", text: $selectedClient)
                .autocorrectionDisabled()

            if !availableClients.isEmpty {
                ForEach(availableClients, id: \.self) { client in
                    Button(client) {
                        selectedClient = client
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
    }

    private var sortSection: some View {
        Section("Sort By") {
            Picker("Sort Order", selection: $sortOrder) {
                ForEach(ExpenseSortOrder.allCases) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }

    private func resetFilters() {
        selectedCategory = nil
        selectedClient = ""
        sortOrder = .dateDescending
    }
}
