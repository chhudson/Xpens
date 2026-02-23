import SwiftUI

struct FeaturedCategoriesPageView: View {
    let categories: [Category]
    @Binding var selectedIDs: [UUID]

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Pick 4 Quick Categories")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("These will appear in the quick-pick grid when adding expenses.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 32)

            List(categories) { category in
                Button {
                    toggle(category)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .foregroundStyle(category.swiftUIColor)
                            .frame(width: 28)
                        Text(category.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        if selectedIDs.contains(category.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.plain)

            Text("\(selectedIDs.count)/4 selected")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
        }
    }

    private func toggle(_ category: Category) {
        if let index = selectedIDs.firstIndex(of: category.id) {
            selectedIDs.remove(at: index)
        } else {
            guard selectedIDs.count < 4 else { return }
            selectedIDs.append(category.id)
        }
    }
}
