//
//  DashboardView.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authService: AuthService

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

                // Feature Voting Section (Placeholder)
                VStack(spacing: 16) {
                    Text("Feature Voting System")
                        .font(.title)
                        .fontWeight(.medium)

                    Text("Coming Soon...")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("This is where users will be able to:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("View feature requests")
                        }
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Upvote and downvote features")
                        }
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Submit new feature ideas")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)

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
        }
    }
}