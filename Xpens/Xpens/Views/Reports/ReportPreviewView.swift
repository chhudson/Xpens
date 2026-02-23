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

    private var categoryBreakdown: [(Category, Decimal, Int)] {
        let grouped = Dictionary(grouping: expenses) { $0.category?.id }
        return grouped.compactMap { (_, items) in
            guard let category = items.first?.category else { return nil }
            let sum = items.reduce(Decimal.zero) { $0 + $1.amount }
            return (category, sum, items.count)
        }
        .sorted { $0.0.sortOrder < $1.0.sortOrder }
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
                ForEach(categoryBreakdown, id: \.0.id) { category, amount, count in
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundStyle(category.swiftUIColor)
                            .frame(width: 24)
                        Text(category.name)
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
