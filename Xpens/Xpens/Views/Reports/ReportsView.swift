import SwiftUI
import SwiftData
import Charts

struct ReportsView: View {

    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]

    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var selectedClient: String?

    private var clients: [String] {
        Array(Set(allExpenses.map(\.client)))
            .filter { !$0.isEmpty }
            .sorted()
    }

    private var filteredExpenses: [Expense] {
        allExpenses.filter { expense in
            let startOfDay = Calendar.current.startOfDay(for: startDate)
            guard let endOfDay = Calendar.current.date(
                byAdding: .day, value: 1,
                to: Calendar.current.startOfDay(for: endDate)
            ) else { return false }
            let inRange = expense.date >= startOfDay && expense.date < endOfDay
            let matchesClient = selectedClient == nil
                || expense.client == selectedClient
            return inRange && matchesClient
        }
    }

    private var total: Decimal {
        filteredExpenses.reduce(.zero) { $0 + $1.amount }
    }

    private var categoryData: [(ExpenseCategory, Decimal)] {
        let grouped = Dictionary(grouping: filteredExpenses) { $0.category }
        return ExpenseCategory.allCases.compactMap { category in
            guard let items = grouped[category] else { return nil }
            let sum = items.reduce(Decimal.zero) { $0 + $1.amount }
            return (category, sum)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Date Range") {
                    DateRangePickerView(
                        startDate: $startDate,
                        endDate: $endDate
                    )
                }

                if !clients.isEmpty {
                    Section("Client") {
                        Picker("Client", selection: $selectedClient) {
                            Text("All Clients").tag(nil as String?)
                            ForEach(clients, id: \.self) { client in
                                Text(client).tag(client as String?)
                            }
                        }
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.string(from: total))
                            .font(.system(size: 34, weight: .bold))
                        Text(
                            "\(filteredExpenses.count) expense\(filteredExpenses.count == 1 ? "" : "s")"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                if !categoryData.isEmpty {
                    Section("By Category") {
                        Chart(categoryData, id: \.0) { category, amount in
                            BarMark(
                                x: .value("Amount", (amount as NSDecimalNumber).doubleValue),
                                y: .value("Category", category.displayName)
                            )
                            .foregroundStyle(category.color)
                            .annotation(position: .trailing, alignment: .leading) {
                                Text(CurrencyFormatter.string(from: amount))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .chartXAxis(.hidden)
                        .frame(height: CGFloat(categoryData.count) * 50)
                    }
                }

                Section {
                    NavigationLink {
                        ReportPreviewView(
                            expenses: filteredExpenses,
                            startDate: startDate,
                            endDate: endDate
                        )
                    } label: {
                        Label("View Full Report", systemImage: "doc.text.magnifyingglass")
                    }
                    .disabled(filteredExpenses.isEmpty)
                }
            }
            .navigationTitle("Reports")
        }
    }
}
