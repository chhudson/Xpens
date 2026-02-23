import SwiftUI

struct AddExpenseView: View {
    @State private var showingManualEntry = false
    @State private var showingCamera = false
    @State private var showingSourcePicker = false
    @State private var isProcessingOCR = false
    @State private var ocrError: String?
    @State private var showingOCRError = false

    // Pre-fill values from OCR
    @State private var prefillAmount: Decimal?
    @State private var prefillDate: Date?
    @State private var prefillMerchant: String?
    @State private var prefillReceiptPath: String?

    @State private var cameraSourceType: UIImagePickerController.SourceType = .camera

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 24) {
                    Spacer()

                    ActionButton(
                        title: "Scan Receipt",
                        icon: "doc.text.viewfinder",
                        color: .blue
                    ) {
                        showingSourcePicker = true
                    }

                    ActionButton(
                        title: "Manual Entry",
                        icon: "square.and.pencil",
                        color: .green
                    ) {
                        clearPrefill()
                        showingManualEntry = true
                    }

                    Spacer()
                }
                .padding(.horizontal, 32)

                if isProcessingOCR {
                    OCRLoadingOverlay()
                }
            }
            .navigationTitle("Add Expense")
            .confirmationDialog("Receipt Source", isPresented: $showingSourcePicker) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Camera") {
                        cameraSourceType = .camera
                        showingCamera = true
                    }
                }
                Button("Photo Library") {
                    cameraSourceType = .photoLibrary
                    showingCamera = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(sourceType: cameraSourceType) { image in
                    showingCamera = false
                    processImage(image)
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualEntryView(
                    prefillAmount: prefillAmount,
                    prefillDate: prefillDate,
                    prefillMerchant: prefillMerchant,
                    receiptImagePath: prefillReceiptPath
                )
            }
            .alert("OCR Failed", isPresented: $showingOCRError) {
                Button("Enter Manually") {
                    showingManualEntry = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(ocrError ?? "Could not read the receipt.")
            }
        }
    }

    private func clearPrefill() {
        prefillAmount = nil
        prefillDate = nil
        prefillMerchant = nil
        prefillReceiptPath = nil
    }

    private func processImage(_ image: UIImage) {
        isProcessingOCR = true
        Task {
            do {
                let path = try ImageStorageService.save(image)
                let result = try await OCRService.shared.recognizeText(from: image)

                prefillAmount = result.extractedAmount
                prefillDate = result.extractedDate
                prefillMerchant = result.extractedMerchant
                prefillReceiptPath = path

                isProcessingOCR = false
                showingManualEntry = true
            } catch {
                isProcessingOCR = false
                ocrError = error.localizedDescription
                showingOCRError = true
            }
        }
    }
}

// MARK: - Subviews

private struct OCRLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                Text("Reading receipt...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 64)
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
    }
}
