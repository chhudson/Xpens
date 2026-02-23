import SwiftUI

enum DateRangePreset: String, CaseIterable, Identifiable {
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisQuarter = "This Quarter"
    case thisYear = "This Year"
    case custom = "Custom"

    var id: String { rawValue }
}

struct DateRangePickerView: View {

    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var selectedPreset: DateRangePreset = .thisMonth

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DateRangePreset.allCases) { preset in
                        Button {
                            selectedPreset = preset
                            applyPreset(preset)
                        } label: {
                            Text(preset.rawValue)
                                .font(.subheadline)
                                .fontWeight(
                                    selectedPreset == preset ? .semibold : .regular
                                )
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    selectedPreset == preset
                                        ? Color.accentColor
                                        : Color(.secondarySystemFill)
                                )
                                .foregroundStyle(
                                    selectedPreset == preset ? .white : .primary
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 1)
            }

            if selectedPreset == .custom {
                HStack {
                    DatePicker(
                        "From",
                        selection: $startDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()

                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)

                    DatePicker(
                        "To",
                        selection: $endDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            }
        }
        .onAppear { applyPreset(.thisMonth) }
    }

    private func applyPreset(_ preset: DateRangePreset) {
        let calendar = Calendar.current
        let now = Date()

        switch preset {
        case .thisMonth:
            startDate = calendar.date(
                from: calendar.dateComponents([.year, .month], from: now)
            )!
            endDate = now

        case .lastMonth:
            let firstOfThisMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: now)
            )!
            startDate = calendar.date(
                byAdding: .month, value: -1, to: firstOfThisMonth
            )!
            endDate = calendar.date(
                byAdding: .day, value: -1, to: firstOfThisMonth
            )!

        case .thisQuarter:
            let month = calendar.component(.month, from: now)
            let quarterStart = ((month - 1) / 3) * 3 + 1
            var components = calendar.dateComponents([.year], from: now)
            components.month = quarterStart
            components.day = 1
            startDate = calendar.date(from: components)!
            endDate = now

        case .thisYear:
            var components = calendar.dateComponents([.year], from: now)
            components.month = 1
            components.day = 1
            startDate = calendar.date(from: components)!
            endDate = now

        case .custom:
            break
        }
    }
}
