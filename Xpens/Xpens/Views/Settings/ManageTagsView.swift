import SwiftUI
import SwiftData

struct ManageTagsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var tags: [Tag]

    @State private var showingAddSheet = false

    var body: some View {
        List {
            if tags.isEmpty {
                ContentUnavailableView(
                    "No Tags",
                    systemImage: "tag",
                    description: Text("Add tags to organize your expenses.")
                )
            }

            ForEach(tags) { tag in
                NavigationLink {
                    EditTagView(tag: tag)
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(tag.swiftUIColor)
                            .frame(width: 12, height: 12)
                        Text(tag.name)
                    }
                }
            }
            .onDelete { offsets in
                for index in offsets {
                    modelContext.delete(tags[index])
                }
            }
        }
        .accessibilityIdentifier(AccessibilityID.ManageTags.list)
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier(AccessibilityID.ManageTags.addButton)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTagView()
        }
    }
}

// MARK: - Add Tag

private struct AddTagView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var color = "#4CAF50"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                HStack {
                    Text("Color")
                    Spacer()
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 24, height: 24)
                }
                TextField("Hex Color", text: $color)
            }
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let tag = Tag(name: name, color: color)
                        modelContext.insert(tag)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Tag

private struct EditTagView: View {
    @Bindable var tag: Tag

    var body: some View {
        Form {
            TextField("Name", text: $tag.name)
            HStack {
                Text("Color")
                Spacer()
                Circle()
                    .fill(tag.swiftUIColor)
                    .frame(width: 24, height: 24)
            }
            TextField("Hex Color", text: $tag.color)
        }
        .navigationTitle("Edit Tag")
        .navigationBarTitleDisplayMode(.inline)
    }
}
