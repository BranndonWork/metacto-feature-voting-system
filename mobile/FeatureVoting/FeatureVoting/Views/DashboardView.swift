//
//  DashboardView.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authService: AuthService
    @State private var featureService: FeatureService?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Welcome Section
                VStack {
                    Text("Welcome!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    if let user = authService.currentUser {
                        Text("Hello, \(user.username)")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        Text("Email: \(user.email)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 50)

                // Feature Voting Section
                if let featureService = featureService {
                    FeatureListView(featureService: featureService)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        ProgressView()
                        Text("Loading...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Spacer()

                // Logout Button
                Button(action: {
                    authService.logout()
                }) {
                    Text("Logout")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
            .navigationBarHidden(true)
            .onAppear {
                if featureService == nil {
                    featureService = FeatureService(authService: authService)
                }
            }
        }
    }
}