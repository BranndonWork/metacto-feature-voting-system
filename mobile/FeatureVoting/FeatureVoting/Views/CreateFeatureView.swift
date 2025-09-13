//
//  CreateFeatureView.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import SwiftUI

struct CreateFeatureView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var featureService: FeatureService

    @State private var title = ""
    @State private var description = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    // Title Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Feature Title")
                            .font(.headline)
                        TextField("Enter feature title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // Description Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.headline)
                        TextField("Describe the feature...", text: $description, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }

                    // Error Message
                    if let errorMessage = featureService.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Create Button
                Button(action: createFeature) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text("Create Feature")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isLoading || !isFormValid)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("New Feature")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func createFeature() {
        isLoading = true

        Task {
            await featureService.createFeature(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines)
            )

            await MainActor.run {
                isLoading = false
                if featureService.errorMessage == nil {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}