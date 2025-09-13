//
//  FeatureListView.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import SwiftUI

struct FeatureListView: View {
    @ObservedObject var featureService: FeatureService
    var onAuthRequired: ((String) -> Void)?
    @State private var showingCreateFeature = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with Create Button
            HStack {
                Text("Features")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button(action: {
                    if featureService.isAuthenticated() {
                        showingCreateFeature = true
                    } else {
                        onAuthRequired?("You need to be logged in to create features.")
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)

            if featureService.isLoading && featureService.features.isEmpty {
                // Loading state
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading features...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if featureService.features.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)

                    Text("No Features Yet")
                        .font(.title2)
                        .fontWeight(.medium)

                    Text("Be the first to suggest a feature!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        if featureService.isAuthenticated() {
                            showingCreateFeature = true
                        } else {
                            onAuthRequired?("You need to be logged in to create features.")
                        }
                    }) {
                        Text("Suggest a Feature")
                            .fontWeight(.medium)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Feature list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(featureService.features) { feature in
                            FeatureRowView(
                                feature: feature,
                                onVote: { featureId, voteType in
                                    if featureService.isAuthenticated() {
                                        Task {
                                            await featureService.vote(on: featureId, voteType: voteType)
                                        }
                                    } else {
                                        onAuthRequired?("You need to be logged in to vote on features.")
                                    }
                                },
                                onDelete: { featureId in
                                    if featureService.isAuthenticated() {
                                        Task {
                                            await featureService.deleteFeature(featureId)
                                        }
                                    } else {
                                        onAuthRequired?("You need to be logged in to delete features.")
                                    }
                                },
                                currentUserId: featureService.authService.currentUser?.id
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .refreshable {
                    await featureService.loadFeatures()
                }
            }

            // Error message
            if let errorMessage = featureService.errorMessage {
                HStack {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)

                    Spacer()

                    Button("Retry") {
                        Task {
                            await featureService.loadFeatures()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            }
        }
        .sheet(isPresented: $showingCreateFeature) {
            CreateFeatureView(featureService: featureService)
        }
        .onAppear {
            Task {
                await featureService.loadFeatures()
            }
        }
    }
}