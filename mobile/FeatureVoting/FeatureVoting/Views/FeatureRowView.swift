//
//  FeatureRowView.swift
//  FeatureVoting
//
//  Created by Branndon Coelho on 9/13/25.
//

import SwiftUI

struct FeatureRowView: View {
    let feature: Feature
    let onVote: (String, String) -> Void
    let onDelete: ((String) -> Void)?
    let currentUserId: Int?

    init(feature: Feature, onVote: @escaping (String, String) -> Void, onDelete: ((String) -> Void)? = nil, currentUserId: Int? = nil) {
        self.feature = feature
        self.onVote = onVote
        self.onDelete = onDelete
        self.currentUserId = currentUserId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Feature Title and Description
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(feature.title)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()

                    // Delete button (only show for current user's features)
                    if let currentUserId = currentUserId,
                       currentUserId == feature.author.id {
                        Button(action: {
                            onDelete?(feature.id)
                        }) {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                if let description = feature.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }

            // Vote Section
            HStack {
                // Upvote Button
                Button(action: {
                    onVote(feature.id, "upvote")
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: feature.userVote == "upvote" ? "arrow.up.circle.fill" : "arrow.up.circle")
                            .font(.title2)
                            .foregroundColor(feature.userVote == "upvote" ? .white : .gray)
                        Text("\(feature.upvoteCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(feature.userVote == "upvote" ? .white : .primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(feature.userVote == "upvote" ? Color.green : Color.clear)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Spacer().frame(width: 16)

                // Downvote Button
                Button(action: {
                    onVote(feature.id, "downvote")
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: feature.userVote == "downvote" ? "arrow.down.circle.fill" : "arrow.down.circle")
                            .font(.title2)
                            .foregroundColor(feature.userVote == "downvote" ? .white : .gray)
                        Text("\(feature.downvoteCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(feature.userVote == "downvote" ? .white : .primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(feature.userVote == "downvote" ? Color.red : Color.clear)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                // Total Score
                HStack(spacing: 4) {
                    Text("Score:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(feature.totalScore)")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(feature.totalScore >= 0 ? .green : .red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(feature.totalScore >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        )
                }
            }

            // Meta Information
            HStack {
                Text("by \(feature.createdBy)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(formatDate(feature.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}