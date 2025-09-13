//
//  Feature.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import Foundation

struct Author: Codable {
    let id: Int
    let username: String
}

struct Feature: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?  // Optional since FeatureListSerializer doesn't include it
    let upvoteCount: Int
    let downvoteCount: Int
    let totalScore: Int
    let author: Author
    let createdAt: String
    let userVote: String?  // Optional since FeatureListSerializer doesn't include it

    enum CodingKeys: String, CodingKey {
        case id, title, description, author
        case upvoteCount = "upvote_count"
        case downvoteCount = "downvote_count"
        case totalScore = "total_score"
        case createdAt = "created_at"
        case userVote = "user_vote"
    }

    var createdBy: String {
        return author.username
    }
}

struct CreateFeatureRequest: Codable {
    let title: String
    let description: String
}

struct VoteRequest: Codable {
    let voteType: String

    enum CodingKeys: String, CodingKey {
        case voteType = "vote_type"
    }
}

struct VoteResponse: Codable {
    let action: String
    let message: String?
}

struct FeatureListResponse: Codable {
    let results: [Feature]
}