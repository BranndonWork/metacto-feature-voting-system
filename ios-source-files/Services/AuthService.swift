//
//  AuthService.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import Foundation
import SwiftUI

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?

    private let baseURL = "http://127.0.0.1:8000/api/auth"
    private var accessToken: String?
    private var refreshToken: String?

    init() {
        loadStoredTokens()
    }

    // MARK: - Authentication Methods

    func register(username: String, email: String, password: String, passwordConfirm: String) async {
        await MainActor.run {
            self.errorMessage = nil
        }

        let request = RegisterRequest(
            username: username,
            email: email,
            password: password,
            passwordConfirm: passwordConfirm
        )

        guard let url = URL(string: "\(baseURL)/register/") else {
            await MainActor.run {
                self.errorMessage = "Invalid URL"
            }
            return
        }

        do {
            let (data, response) = try await performRequest(url: url, httpMethod: "POST", body: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                    await handleSuccessfulAuth(authResponse)
                } else {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    await MainActor.run {
                        self.errorMessage = errorResponse.message
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }

    func login(username: String, password: String) async {
        await MainActor.run {
            self.errorMessage = nil
        }

        let request = AuthRequest(username: username, password: password)

        guard let url = URL(string: "\(baseURL)/login/") else {
            await MainActor.run {
                self.errorMessage = "Invalid URL"
            }
            return
        }

        do {
            let (data, response) = try await performRequest(url: url, httpMethod: "POST", body: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                    await handleSuccessfulAuth(authResponse)
                } else {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    await MainActor.run {
                        self.errorMessage = errorResponse.message
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }

    func logout() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
            self.accessToken = nil
            self.refreshToken = nil
            self.errorMessage = nil
            self.clearStoredTokens()
        }
    }

    // MARK: - Helper Methods

    private func performRequest<T: Codable>(url: URL, httpMethod: String, body: T) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        return try await URLSession.shared.data(for: request)
    }

    @MainActor
    private func handleSuccessfulAuth(_ authResponse: AuthResponse) {
        self.currentUser = authResponse.user
        self.isAuthenticated = true
        self.accessToken = authResponse.tokens.access
        self.refreshToken = authResponse.tokens.refresh
        storeTokens()
    }

    // MARK: - Token Storage

    private func storeTokens() {
        UserDefaults.standard.set(accessToken, forKey: "access_token")
        UserDefaults.standard.set(refreshToken, forKey: "refresh_token")

        if let userData = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(userData, forKey: "current_user")
        }
    }

    private func loadStoredTokens() {
        accessToken = UserDefaults.standard.string(forKey: "access_token")
        refreshToken = UserDefaults.standard.string(forKey: "refresh_token")

        if let userData = UserDefaults.standard.data(forKey: "current_user"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isAuthenticated = accessToken != nil
        }
    }

    private func clearStoredTokens() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "current_user")
    }
}