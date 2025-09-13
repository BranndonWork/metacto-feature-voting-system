//
//  AuthenticationView.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isLoginMode = true
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirm = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Text("Feature Voting")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(isLoginMode ? "Sign in to continue" : "Create your account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)

                // Form
                VStack(spacing: 16) {
                    // Username Field
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    // Email Field (only for registration)
                    if !isLoginMode {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }

                    // Password Field
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            if isFormValid && !isLoading {
                                performAction()
                            }
                        }

                    // Confirm Password Field (only for registration)
                    if !isLoginMode {
                        SecureField("Confirm Password", text: $passwordConfirm)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                if isFormValid && !isLoading {
                                    performAction()
                                }
                            }
                    }

                    // Error Message
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }

                    // Action Button
                    Button(action: performAction) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoginMode ? "Sign In" : "Sign Up")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading || !isFormValid)
                }
                .padding(.horizontal, 30)

                // Toggle Mode
                Button(action: toggleMode) {
                    Text(isLoginMode ? "Don't have an account? Sign up" : "Already have an account? Sign in")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }

    private var isFormValid: Bool {
        if isLoginMode {
            return !username.isEmpty && !password.isEmpty
        } else {
            return !username.isEmpty && !email.isEmpty && !password.isEmpty && !passwordConfirm.isEmpty
        }
    }

    private func toggleMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isLoginMode.toggle()
            // Clear fields when switching modes
            username = ""
            email = ""
            password = ""
            passwordConfirm = ""
        }
    }

    private func performAction() {
        isLoading = true

        Task {
            if isLoginMode {
                await authService.login(username: username, password: password)
            } else {
                await authService.register(
                    username: username,
                    email: email,
                    password: password,
                    passwordConfirm: passwordConfirm
                )
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }
}