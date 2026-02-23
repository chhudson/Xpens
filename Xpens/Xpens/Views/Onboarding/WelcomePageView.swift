import SwiftUI

struct WelcomePageView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            VStack(spacing: 12) {
                Text("Welcome to Xpens")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Track expenses, scan receipts, and export reports — all on your device.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }
}
