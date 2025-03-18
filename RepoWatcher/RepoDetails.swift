//
//  RepoDetails.swift
//  RepoWatcherWidgetExtension
//
//  Created by Nishant Taneja on 18/03/25.
//

import Foundation

typealias RepoDetailsDecodable = RepoDetails.DetailsDecodableData
typealias RepoContributorsDecodable = RepoDetails.Contributor.ContributorDecodableData

struct RepoDetails {
    let ownerImagePath: String
    let title: String
    let description: String
    let daysSinceLastActivity: Int
    let watchers: Int
    let forks: Int
    let issues: Int
    private(set) var contributors: [Contributor]
    
    mutating func setContributors(_ contributors: [Contributor]) {
        self.contributors = contributors
    }
}

extension RepoDetails {
    static let mockData = RepoDetails(ownerImagePath: "", title: "GitHub Repository", description: "There's no description available for this repository.", daysSinceLastActivity: 5, watchers: 9, forks: 3, issues: 2, contributors: [
        RepoDetails.Contributor(userImagePath: "", username: "username", contributions: 7),
    ])
}

extension RepoDetails {
    struct Contributor: Identifiable {
        let id = UUID()
        let userImagePath: String
        let username: String
        let contributions: Int
    }
}

extension RepoDetails {
    struct DetailsDecodableData: Decodable {
        let name: String?
        let description: String?
        let owner: Owner?
        let hasIssues: Bool?
        let forks: Int?
        let watchers: Int?
        let openIssues: Int?
        let pushedAt: String?
    }
}

extension RepoDetails.DetailsDecodableData {
    struct Owner: Decodable {
        let avatarUrl: String?
    }
}

extension RepoDetails.Contributor {
    struct ContributorDecodableData: Decodable {
        let login: String?
        let avatarUrl: String?
        let contributions: Int?
    }
}

extension RepoDetails.Contributor.ContributorDecodableData {
    var contributor: RepoDetails.Contributor? {
        guard let avatarUrl, let login, let contributions else { return nil }
        return RepoDetails.Contributor(userImagePath: avatarUrl, username: login, contributions: contributions)
    }
}

extension RepoDetails.DetailsDecodableData {
    var details: RepoDetails? {
        guard let name, let avatarUrl = owner?.avatarUrl, let forks, let watchers, let openIssues, let daysSinceLastActivity = pushedAt?.numberOfDaysTillToday else { return nil }
        return RepoDetails(ownerImagePath: avatarUrl, title: name, description: description ?? "No Description. This is a hardcoded text.", daysSinceLastActivity: daysSinceLastActivity, watchers: watchers, forks: forks, issues: openIssues, contributors: [])
    }
}

fileprivate extension ISO8601DateFormatter {
    static let shared = ISO8601DateFormatter()
}

fileprivate extension String {
    var numberOfDaysTillToday: Int? {
        guard let lastActivityDate = ISO8601DateFormatter.shared.date(from: self),
              let daysSinceLastActivity = Calendar.current.dateComponents([.day], from: lastActivityDate, to: .now).day else { return nil }
        return daysSinceLastActivity
    }
}
