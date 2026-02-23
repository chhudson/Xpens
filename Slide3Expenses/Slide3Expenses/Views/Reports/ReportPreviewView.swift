import SwiftUI

struct ReportPreviewView: View {

    let expenses: [Expense]
    let startDate: Date
    let endDate: Date

    @State private var errorMessage: String?
    @State private var shareItem: ShareItem?

    private var total: Decimal {
        expenses.reduce(.zero) { $0 + $1.amount }
    }

    private var categoryBreakdown: [(ExpenseCategory, Decimal, Int)] {
        let grouped = Dictionary(grouping: expenses) { $0.category }
        return ExpenseCategory.allCases.compactMap { category in
            guard let items = grouped[category] else { return nil }
            let sum = items.reduce(Decimal.zero) { $0 + $1.amount }
            return (category, sum, items.count)
        }
    }

    var body: some View {
        List {
            Section("Date Range") {
                HStack {
                    Text(startDate.displayString)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(endDate.displayString)
                }
            }

            Section("Summary") {
                LabeledContent("Total") {
                    Text(CurrencyFormatter.string(from: total))
                        .font(.title3.bold())
                }
                LabeledContent("Expenses") {
                    Text("\(expenses.count)")
                }
            }

            Section("By Category") {
                ForEach(categoryBreakdown, id: \.0) { category, amount, count in
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundStyle(category.color)
                            .frame(width: 24)
                        Text(category.displayName)
                        Spacer()
                        Text("\(count)")
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.string(from: amount))
                            .frame(width: 90, alignment: .trailing)
                    }
                }
            }

            Section {
                Button {
                    exportPDF()
                } label: {
                    Label("Export PDF", systemImage: "doc.richtext")
                }

                Button {
                    exportCSV()
                } label: {
                    Label("Export CSV", systemImage: "tablecells")
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Report Preview")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $shareItem) { item in
            ActivityView(url: item.url)
        }
    }

    private func exportPDF() {
        do {
            let url = try PDFExportService.exportToFile(
                expenses: expenses,
                startDate: startDate,
                endDate: endDate
            )
            shareItem = ShareItem(url: url)
            errorMessage = nil
        } catch {
            errorMessage = "PDF export failed: \(error.localizedDescription)"
        }
    }

    private func exportCSV() {
        do {
            let url = try CSVExportService.exportToFile(expenses: expenses)
            shareItem = ShareItem(url: url)
            errorMessage = nil
        } catch {
            errorMessage = "CSV export failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Identifiable wrapper for sheet

private struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - UIActivityViewController wrapper

private struct ActivityView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(
        context: Context
    ) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {
        // No updates needed
    }
}
