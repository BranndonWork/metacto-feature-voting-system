//
//  FeatureService.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import Foundation
import SwiftUI

class FeatureService: ObservableObject {
    @Published var features: [Feature] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let baseURL = "http://127.0.0.1:8000/api"
    var authService: AuthService
    private var loadTask: Task<Void, Never>?

    init(authService: AuthService) {
        self.authService = authService
    }

    // MARK: - Feature Methods

    func loadFeatures() async {
        // Cancel any existing load task
        loadTask?.cancel()

        // Create new task
        loadTask = Task {
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }

            guard let url = URL(string: "\(baseURL)/features/") else {
                await MainActor.run {
                    self.errorMessage = "Invalid URL"
                    self.isLoading = false
                }
                return
            }

            do {
                let (data, response) = try await performRequest(url: url, httpMethod: "GET", requireAuth: false)

                // Check if task was cancelled
                guard !Task.isCancelled else { return }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        let featureResponse = try JSONDecoder().decode(FeatureListResponse.self, from: data)
                        await MainActor.run {
                            self.features = featureResponse.results
                            self.isLoading = false
                        }
                    } else {
                        await MainActor.run {
                            self.errorMessage = "Failed to load features"
                            self.isLoading = false
                        }
                    }
                }
            } catch {
                // Don't show cancellation errors to user
                if !Task.isCancelled {
                    await MainActor.run {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            }
        }

        await loadTask?.value
    }

    func createFeature(title: String, description: String) async {
        await MainActor.run {
            self.errorMessage = nil
        }

        let request = CreateFeatureRequest(title: title, description: description)

        guard let url = URL(string: "\(baseURL)/feature/") else {
            await MainActor.run {
                self.errorMessage = "Invalid URL"
            }
            return
        }

        do {
            let (data, response) = try await performRequest(url: url, httpMethod: "POST", body: request, requireAuth: true)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    let newFeature = try JSONDecoder().decode(Feature.self, from: data)
                    await MainActor.run {
                        self.features.insert(newFeature, at: 0)
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Failed to create feature"
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }

    func vote(on featureId: String, voteType: String) async {
        await MainActor.run {
            self.errorMessage = nil
        }

        let request = VoteRequest(voteType: voteType)

        guard let url = URL(string: "\(baseURL)/feature/\(featureId)/vote/") else {
            await MainActor.run {
                self.errorMessage = "Invalid URL"
            }
            return
        }

        do {
            let (data, response) = try await performRequest(url: url, httpMethod: "POST", body: request, requireAuth: true)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    // Refresh features to get updated vote counts
                    Task {
                        await loadFeatures()
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Failed to vote"
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }

    func deleteFeature(_ featureId: String) async {
        await MainActor.run {
            self.errorMessage = nil
        }

        guard let url = URL(string: "\(baseURL)/feature/\(featureId)/") else {
            await MainActor.run {
                self.errorMessage = "Invalid URL"
            }
            return
        }

        do {
            let (_, response) = try await performRequest(url: url, httpMethod: "DELETE", requireAuth: true)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    // Remove feature from local list
                    await MainActor.run {
                        self.features.removeAll { $0.id == featureId }
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Failed to delete feature"
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Authentication Check

    func isAuthenticated() -> Bool {
        return authService.isAuthenticated && authService.accessToken != nil
    }

    // MARK: - Helper Methods

    private func performRequest<T: Codable>(url: URL, httpMethod: String, body: T? = nil, requireAuth: Bool = true) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Always add JWT token if available (for user vote states), regardless of requireAuth
        if let accessToken = authService.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        }

        return try await URLSession.shared.data(for: request)
    }

    private func performRequest(url: URL, httpMethod: String, requireAuth: Bool = true) async throws -> (Data, URLResponse) {
        return try await performRequest(url: url, httpMethod: httpMethod, body: Optional<String>.none, requireAuth: requireAuth)
    }
}