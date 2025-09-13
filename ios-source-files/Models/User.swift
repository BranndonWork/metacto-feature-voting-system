//
//  User.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let dateJoined: String

    enum CodingKeys: String, CodingKey {
        case id, username, email
        case dateJoined = "date_joined"
    }
}

struct AuthTokens: Codable {
    let refresh: String
    let access: String
}

struct AuthResponse: Codable {
    let message: String
    let user: User
    let tokens: AuthTokens
}

struct AuthRequest: Codable {
    let username: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
    let passwordConfirm: String

    enum CodingKeys: String, CodingKey {
        case username, email, password
        case passwordConfirm = "password_confirm"
    }
}

struct ErrorResponse: Codable {
    let nonFieldErrors: [String]?
    let username: [String]?
    let email: [String]?
    let password: [String]?

    enum CodingKeys: String, CodingKey {
        case nonFieldErrors = "non_field_errors"
        case username, email, password
    }

    var message: String {
        if let errors = nonFieldErrors {
            return errors.joined(separator: ", ")
        }
        if let errors = username {
            return "Username: " + errors.joined(separator: ", ")
        }
        if let errors = email {
            return "Email: " + errors.joined(separator: ", ")
        }
        if let errors = password {
            return "Password: " + errors.joined(separator: ", ")
        }
        return "Unknown error occurred"
    }
}