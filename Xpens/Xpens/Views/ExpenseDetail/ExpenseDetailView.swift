import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    @Bindable var expense: Expense
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false
    @State private var showingReceipt = false

    var body: some View {
        List {
            headerSection
            detailsSection
            receiptSection
            notesSection
            deleteSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Expense")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            ExpenseEditView(expense: expense)
        }
        .fullScreenCover(isPresented: $showingReceipt) {
            if let path = expense.receiptImagePath {
                ReceiptImageView(imagePath: path)
            }
        }
        .confirmationDialog(
            "Delete Expense",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { deleteExpense() }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        Section {
            HStack {
                Image(systemName: expense.category?.icon ?? "questionmark")
                    .font(.title2)
                    .foregroundStyle(expense.category?.swiftUIColor ?? .gray)
                    .frame(width: 44, height: 44)
                    .background((expense.category?.swiftUIColor ?? .gray).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(expense.merchant)
                        .font(.headline)
                    Text(expense.category?.name ?? "Uncategorized")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(CurrencyFormatter.string(from: expense.amount))
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
        }
    }

    private var detailsSection: some View {
        Section("Details") {
            DetailRow(label: "Date", value: expense.date.displayString)

            if !expense.client.isEmpty {
                DetailRow(label: "Client", value: expense.client)
            }

            DetailRow(
                label: "Category",
                value: expense.category?.name ?? "Uncategorized"
            )

            if let tags = expense.tags, !tags.isEmpty {
                HStack {
                    Text("Tags")
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(tags) { tag in
                            Text(tag.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tag.swiftUIColor.opacity(0.15))
                                .clipShape(Capsule())
                                .foregroundStyle(tag.swiftUIColor)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var receiptSection: some View {
        if let path = expense.receiptImagePath,
           let uiImage = ImageStorageService.loadImage(relativePath: path) {
            Section("Receipt") {
                Button { showingReceipt = true } label: {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var notesSection: some View {
        if !expense.notes.isEmpty {
            Section("Notes") {
                Text(expense.notes)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
    }

    private var deleteSection: some View {
        Section {
            Button("Delete Expense", role: .destructive) {
                showingDeleteConfirm = true
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Actions

    private func deleteExpense() {
        if let path = expense.receiptImagePath {
            try? ImageStorageService.deleteImage(relativePath: path)
        }
        modelContext.delete(expense)
        dismiss()
    }
}

// MARK: - Detail Row

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}

// MARK: - Edit View (wraps existing fields for editing)

struct ExpenseEditView: View {
    @Bindable var expense: Expense
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date
    @State private var category: Category?
    @State private var amount: Decimal?
    @State private var merchant: String
    @State private var client: String
    @State private var notes: String
    @State private var selectedTags: [Tag]
    @State private var showingValidationAlert = false

    init(expense: Expense) {
        self.expense = expense
        _date = State(initialValue: expense.date)
        _category = State(initialValue: expense.category)
        _amount = State(initialValue: expense.amount)
        _merchant = State(initialValue: expense.merchant)
        _client = State(initialValue: expense.client)
        _notes = State(initialValue: expense.notes)
        _selectedTags = State(initialValue: expense.tags ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                }

                Section("Category") {
                    CategoryPicker(selection: $category)
                }

                Section("Tags") {
                    TagPicker(selectedTags: $selectedTags)
                }

                Section("Details") {
                    CurrencyTextField(title: "0.00", amount: $amount)
                    TextField("Merchant", text: $merchant)
                    TextField("Client", text: $client)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
            .alert("Missing Information",
                   isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter an amount greater than zero and a merchant name.")
            }
        }
    }

    private func save() {
        guard let amount, amount > 0,
              !merchant.trimmingCharacters(in: .whitespaces).isEmpty else {
            showingValidationAlert = true
            return
        }

        expense.date = date
        expense.category = category
        expense.tags = selectedTags.isEmpty ? nil : selectedTags
        expense.amount = amount
        expense.merchant = merchant.trimmingCharacters(in: .whitespaces)
        expense.client = client.trimmingCharacters(in: .whitespaces)
        expense.notes = notes.trimmingCharacters(in: .whitespaces)
        dismiss()
    }
}
