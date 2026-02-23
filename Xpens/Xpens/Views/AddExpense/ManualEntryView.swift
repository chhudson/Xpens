import SwiftUI
import SwiftData

struct ManualEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date
    @State private var category: Category?
    @State private var amount: Decimal?
    @State private var merchant: String
    @State private var client: String = ""
    @State private var notes: String = ""
    @State private var selectedTags: [Tag] = []
    @State private var isRecurring = false
    @State private var recurrenceRule = "monthly"
    @State private var showingValidationAlert = false

    let receiptImagePath: String?

    init(
        prefillAmount: Decimal? = nil,
        prefillDate: Date? = nil,
        prefillMerchant: String? = nil,
        receiptImagePath: String? = nil
    ) {
        _date = State(initialValue: prefillDate ?? .now)
        _amount = State(initialValue: prefillAmount)
        _merchant = State(initialValue: prefillMerchant ?? "")
        self.receiptImagePath = receiptImagePath
    }

    var body: some View {
        NavigationStack {
            Form {
                if let receiptImagePath,
                   let image = ImageStorageService.loadImage(relativePath: receiptImagePath) {
                    Section("Receipt") {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(maxWidth: .infinity)
                    }
                }

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
                        .accessibilityIdentifier(AccessibilityID.ManualEntry.amountField)
                    TextField("Merchant", text: $merchant)
                        .accessibilityIdentifier(AccessibilityID.ManualEntry.merchantField)
                    TextField("Client", text: $client)
                        .accessibilityIdentifier(AccessibilityID.ManualEntry.clientField)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .accessibilityIdentifier(AccessibilityID.ManualEntry.notesField)
                        .lineLimit(3...6)
                }

                Section {
                    Toggle("Make Recurring", isOn: $isRecurring)
                        .accessibilityIdentifier(AccessibilityID.ManualEntry.recurringToggle)

                    if isRecurring {
                        Picker("Frequency", selection: $recurrenceRule) {
                            Text("Weekly").tag("weekly")
                            Text("Monthly").tag("monthly")
                            Text("Yearly").tag("yearly")
                        }
                        .accessibilityIdentifier(AccessibilityID.ManualEntry.frequencyPicker)
                    }
                } footer: {
                    if isRecurring {
                        Text("A new expense will be created automatically at this frequency.")
                    }
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier(AccessibilityID.ManualEntry.cancelButton)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .accessibilityIdentifier(AccessibilityID.ManualEntry.saveButton)
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

        let expense = Expense(
            date: date,
            category: category,
            tags: selectedTags.isEmpty ? nil : selectedTags,
            amount: amount,
            merchant: merchant.trimmingCharacters(in: .whitespaces),
            client: client.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces),
            receiptImagePath: receiptImagePath,
            isRecurring: isRecurring,
            recurrenceRule: isRecurring ? recurrenceRule : nil
        )
        modelContext.insert(expense)
        dismiss()
    }
}
