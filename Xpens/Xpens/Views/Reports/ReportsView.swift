import SwiftUI
import SwiftData
import Charts

struct ReportsView: View {

    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]

    @Query(sort: \Tag.name) private var allTags: [Tag]

    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var selectedClient: String?
    @State private var selectedTagIDs: Set<UUID> = []

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
            let matchesTags = selectedTagIDs.isEmpty
                || !(expense.tags ?? []).filter { selectedTagIDs.contains($0.id) }.isEmpty
            return inRange && matchesClient && matchesTags
        }
    }

    private var total: Decimal {
        filteredExpenses.reduce(.zero) { $0 + $1.amount }
    }

    private var categoryData: [(Category, Decimal)] {
        let grouped = Dictionary(grouping: filteredExpenses) { $0.category?.id }
        return grouped.compactMap { (_, items) in
            guard let category = items.first?.category else { return nil }
            let sum = items.reduce(Decimal.zero) { $0 + $1.amount }
            return (category, sum)
        }
        .sorted { $0.0.sortOrder < $1.0.sortOrder }
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

                if !allTags.isEmpty {
                    Section("Tags") {
                        ForEach(allTags) { tag in
                            Button {
                                if selectedTagIDs.contains(tag.id) {
                                    selectedTagIDs.remove(tag.id)
                                } else {
                                    selectedTagIDs.insert(tag.id)
                                }
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(tag.swiftUIColor)
                                        .frame(width: 10, height: 10)
                                    Text(tag.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selectedTagIDs.contains(tag.id) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
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
                        Chart(categoryData, id: \.0.id) { category, amount in
                            BarMark(
                                x: .value("Amount", (amount as NSDecimalNumber).doubleValue),
                                y: .value("Category", category.name)
                            )
                            .foregroundStyle(category.swiftUIColor)
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
