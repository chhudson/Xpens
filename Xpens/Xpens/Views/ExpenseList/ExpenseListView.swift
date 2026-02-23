import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]

    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedClient = ""
    @State private var selectedTags: Set<UUID> = []
    @State private var sortOrder: ExpenseSortOrder = .dateDescending
    @State private var showingFilter = false
    @State private var showingAddExpense = false

    var body: some View {
        NavigationStack {
            Group {
                if allExpenses.isEmpty {
                    emptyState
                } else {
                    expenseList
                }
            }
            .navigationTitle("Expenses")
            .searchable(text: $searchText, prompt: "Search merchant or client")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    filterButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingFilter) {
                ExpenseFilterView(
                    selectedCategory: $selectedCategory,
                    selectedClient: $selectedClient,
                    selectedTags: $selectedTags,
                    sortOrder: $sortOrder,
                    availableClients: uniqueClients
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingAddExpense) {
                ManualEntryView()
            }
        }
    }

    // MARK: - Recurring Templates

    private var recurringTemplates: [Expense] {
        allExpenses.filter { $0.isRecurring }
    }

    // MARK: - Filtered + Sorted Data

    private var filteredExpenses: [Expense] {
        var result = allExpenses.filter { !$0.isRecurring }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.merchant.lowercased().contains(query) ||
                $0.client.lowercased().contains(query)
            }
        }

        if let category = selectedCategory {
            result = result.filter { $0.category?.id == category.id }
        }

        if !selectedClient.isEmpty {
            let client = selectedClient.lowercased()
            result = result.filter {
                $0.client.lowercased().contains(client)
            }
        }

        if !selectedTags.isEmpty {
            result = result.filter { expense in
                guard let tags = expense.tags else { return false }
                return !selectedTags.isDisjoint(with: Set(tags.map(\.id)))
            }
        }

        return sorted(result)
    }

    private func sorted(_ expenses: [Expense]) -> [Expense] {
        switch sortOrder {
        case .dateDescending:
            expenses.sorted { $0.date > $1.date }
        case .dateAscending:
            expenses.sorted { $0.date < $1.date }
        case .amountDescending:
            expenses.sorted { $0.amount > $1.amount }
        case .amountAscending:
            expenses.sorted { $0.amount < $1.amount }
        }
    }

    private var groupedByMonth: [(String, [Expense])] {
        let dict = Dictionary(grouping: filteredExpenses) { $0.date.sectionHeader }
        return dict.sorted { lhs, rhs in
            guard let ld = lhs.value.first?.date,
                  let rd = rhs.value.first?.date else { return false }
            return sortOrder == .dateAscending ? ld < rd : ld > rd
        }
    }

    private var totalAmount: Decimal {
        filteredExpenses.reduce(Decimal.zero) { $0 + $1.amount }
    }

    private var uniqueClients: [String] {
        Array(Set(allExpenses.compactMap {
            $0.client.isEmpty ? nil : $0.client
        })).sorted()
    }

    private var hasActiveFilters: Bool {
        selectedCategory != nil || !selectedClient.isEmpty ||
        !selectedTags.isEmpty || sortOrder != .dateDescending
    }

    // MARK: - Subviews

    private var expenseList: some View {
        List {
            totalSection

            if !recurringTemplates.isEmpty {
                Section("Recurring") {
                    ForEach(recurringTemplates) { template in
                        RecurringExpenseRow(expense: template)
                    }
                    .onDelete { offsets in
                        deleteRecurringTemplates(at: offsets)
                    }
                }
            }

            ForEach(groupedByMonth, id: \.0) { header, expenses in
                Section(header) {
                    ForEach(expenses) { expense in
                        NavigationLink(value: expense.id) {
                            ExpenseRowView(expense: expense)
                        }
                    }
                    .onDelete { offsets in
                        deleteExpenses(expenses, at: offsets)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: UUID.self) { id in
            if let expense = allExpenses.first(where: { $0.id == id }) {
                ExpenseDetailView(expense: expense)
            }
        }
    }

    private var totalSection: some View {
        Section {
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(CurrencyFormatter.string(from: totalAmount))
                    .font(.headline)
                    .monospacedDigit()
            }
        }
    }

    private var filterButton: some View {
        Button {
            showingFilter = true
        } label: {
            Image(systemName: hasActiveFilters
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Expenses",
            systemImage: "tray",
            description: Text("Tap + to add your first expense.")
        )
    }

    // MARK: - Actions

    private func deleteExpenses(
        _ sectionExpenses: [Expense],
        at offsets: IndexSet
    ) {
        for index in offsets {
            let expense = sectionExpenses[index]
            if let path = expense.receiptImagePath {
                try? ImageStorageService.deleteImage(relativePath: path)
            }
            modelContext.delete(expense)
        }
    }

    private func deleteRecurringTemplates(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recurringTemplates[index])
        }
    }
}
