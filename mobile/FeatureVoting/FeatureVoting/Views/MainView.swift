//
//  MainView.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authService: AuthService
    @State private var featureService: FeatureService?
    @State private var showingAuth = false
    @State private var authPromptMessage = ""
    @State private var showingAuthPrompt = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with auth buttons
                HStack {
                    Text("Feature Voting")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()

                    if authService.isAuthenticated {
                        // User menu
                        Menu {
                            if let user = authService.currentUser {
                                Text("Hello, \(user.username)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Divider()
                            }
                            Button("Logout", action: authService.logout)
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    } else {
                        // Login/Register buttons
                        HStack(spacing: 8) {
                            Button("Login") {
                                showingAuth = true
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)

                            Button("Register") {
                                showingAuth = true
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)

                // Feature list
                if let featureService = featureService {
                    FeatureListView(
                        featureService: featureService,
                        onAuthRequired: { message in
                            authPromptMessage = message
                            showingAuthPrompt = true
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        ProgressView()
                        Text("Loading features...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if featureService == nil {
                    featureService = FeatureService(authService: authService)
                }
            }
        }
        .sheet(isPresented: $showingAuth) {
            AuthenticationView()
                .environmentObject(authService)
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                showingAuth = false
                // Refresh features to get user vote states
                if let featureService = featureService {
                    Task {
                        await featureService.loadFeatures()
                    }
                }
            }
        }
        .alert("Login Required", isPresented: $showingAuthPrompt) {
            Button("Login") {
                showingAuth = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(authPromptMessage)
        }
    }
}