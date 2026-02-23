import SwiftUI
import SwiftData

struct TagPicker: View {
    @Binding var selectedTags: [Tag]
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @State private var showingNewTag = false
    @State private var newTagName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allTags) { tag in
                        TagChip(
                            tag: tag,
                            isSelected: selectedTags.contains { $0.id == tag.id }
                        )
                        .onTapGesture { toggle(tag) }
                    }

                    Button {
                        showingNewTag = true
                    } label: {
                        Label("New", systemImage: "plus")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.tertiarySystemBackground))
                            .clipShape(Capsule())
                    }
                    .accessibilityIdentifier(AccessibilityID.TagPicker.newButton)
                    .foregroundStyle(.primary)
                }
                .padding(.horizontal, 1)
            }

            if showingNewTag {
                HStack {
                    TextField("Tag name", text: $newTagName)
                        .accessibilityIdentifier(AccessibilityID.TagPicker.tagNameField)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                    Button("Add") {
                        createTag()
                    }
                    .accessibilityIdentifier(AccessibilityID.TagPicker.addButton)
                    .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                    Button("Cancel") {
                        showingNewTag = false
                        newTagName = ""
                    }
                    .accessibilityIdentifier(AccessibilityID.TagPicker.cancelButton)
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func toggle(_ tag: Tag) {
        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }

    private func createTag() {
        let name = newTagName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let tag = Tag(name: name, color: "#607D8B")
        modelContext.insert(tag)
        selectedTags.append(tag)
        newTagName = ""
        showingNewTag = false
    }
}

// MARK: - Tag Chip

struct TagChip: View {
    let tag: Tag
    let isSelected: Bool

    var body: some View {
        Text(tag.name)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                isSelected
                    ? tag.swiftUIColor.opacity(0.2)
                    : Color(.secondarySystemBackground)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? tag.swiftUIColor : .clear, lineWidth: 1.5)
            )
            .clipShape(Capsule())
            .foregroundStyle(isSelected ? tag.swiftUIColor : .primary)
    }
}
