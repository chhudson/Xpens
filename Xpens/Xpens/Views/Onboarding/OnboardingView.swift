import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var currentPage = 0
    @State private var currencyCode = "USD"
    @State private var featuredIDs: [UUID] = []
    @State private var defaultCategories: [Category] = []

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                WelcomePageView()
                    .tag(0)

                CurrencySelectionPageView(selectedCode: $currencyCode)
                    .tag(1)

                FeaturedCategoriesPageView(
                    categories: defaultCategories,
                    selectedIDs: $featuredIDs
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)

            HStack {
                Button("Skip") {
                    completeOnboarding()
                }
                .accessibilityIdentifier(AccessibilityID.Onboarding.skipButton)
                .foregroundStyle(.secondary)

                Spacer()

                if currentPage < 2 {
                    Button("Next") {
                        currentPage += 1
                    }
                    .accessibilityIdentifier(AccessibilityID.Onboarding.nextButton)
                    .fontWeight(.semibold)
                } else {
                    Button("Get Started") {
                        completeOnboarding()
                    }
                    .accessibilityIdentifier(AccessibilityID.Onboarding.getStartedButton)
                    .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .onAppear {
            seedDefaultCategories()
        }
    }

    private func seedDefaultCategories() {
        let categories = Category.createDefaults()
        for cat in categories {
            modelContext.insert(cat)
        }
        defaultCategories = categories

        // Pre-select first 4 as featured
        featuredIDs = Array(categories.prefix(4).map(\.id))
    }

    private func completeOnboarding() {
        CurrencyFormatter.setCurrency(code: currencyCode)

        let prefs = UserPreferences(
            currencyCode: currencyCode,
            hasCompletedOnboarding: true,
            featuredCategoryIDs: featuredIDs
        )
        modelContext.insert(prefs)
    }
}
