//
//  RepoContributorsWidget.swift
//  RepoWatcherWidgetExtension
//
//  Created by Nishant Taneja on 18/03/25.
//

import SwiftUI
import WidgetKit

fileprivate struct RepoContributorEntry: TimelineEntry {
    let date: Date
    let details: RepoDetails
}

fileprivate extension RepoContributorEntry {
    static let mockData = RepoContributorEntry(date: .now, details: RepoDetails(ownerImagePath: "", title: "Hello, GitHub", description: "There's no description available for this repository.", daysSinceLastActivity: 5, watchers: 9, forks: 3, issues: 2, contributors: [
        RepoDetails.Contributor(userImagePath: "", username: "C-1", contributions: 6),
        RepoDetails.Contributor(userImagePath: "", username: "C-2", contributions: 5),
        RepoDetails.Contributor(userImagePath: "", username: "C-3", contributions: 4),
        RepoDetails.Contributor(userImagePath: "", username: "C-4", contributions: 3)
    ]))
}

fileprivate struct RepoContributorsProvider: TimelineProvider {
    typealias Entry = RepoContributorEntry
    
    func placeholder(in context: Context) -> RepoContributorEntry {
        .mockData
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RepoContributorEntry) -> Void) {
        completion(.mockData)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RepoContributorEntry>) -> Void) {
        Task {
            var repoDetails: RepoDetails
            do {
                let decodedRepoResponse = try await URLSession.shared.data(ofType: RepoDetailsDecodable.self, from: "https://api.github.com/repos/google/GoogleSignIn-iOS")
                repoDetails = decodedRepoResponse.details ?? .mockData
                let decodedContributorsResponse = try await URLSession.shared.data(ofType: [RepoContributorsDecodable].self, from: "https://api.github.com/repos/google/GoogleSignIn-iOS/contributors")
                let decodedContributors = decodedContributorsResponse.sorted(by: { ($0.contributions ?? .zero) >= ($1.contributions ?? .zero) }).prefix(6).compactMap({ $0.contributor })
                repoDetails.setContributors(decodedContributors)
            } catch {
                debugPrint(#function, error)
                repoDetails = .mockData
            }
            let timeline: Timeline<RepoContributorEntry> = Timeline(entries: [RepoContributorEntry(date: .now, details: repoDetails)], policy: .never)
            completion(timeline)
        }
    }
}

fileprivate struct RepoContributorsView: View {
    private let details: RepoDetails
    
    init(_ details: RepoDetails) {
        self.details = details
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            RepoDetailsView(details)        // Repo Details
            Spacer().frame(height: 16)
            Text("Top Contributors")         // Contributors List View
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), alignment: .leading, spacing: 8) {
                ForEach(details.contributors) { contributor in
                    HStack {
                        HStack {        // Image and title
                            Circle()
                                .frame(width: 36, height: 36)
                            VStack(alignment: .leading) {
                                Text(contributor.username)
                                    .font(.caption)
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                                Text("\(contributor.contributions)")
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .minimumScaleFactor(0.7)
                            }
                        }
                    }
                }
            }
        }
        .containerBackground(for: .widget) { }
    }
}

struct RepoContributorsWidget: Widget {
    private let kind = "RepoContributorsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RepoContributorsProvider()) { entry in
            RepoContributorsView(entry.details)
        }
        .configurationDisplayName("Contributors")
        .description("Keep track of a repository's top contributors.")
        .supportedFamilies([.systemLarge])
    }
}

#Preview(as: .systemLarge, widget: {
    RepoContributorsWidget()
}, timeline: {
    RepoContributorEntry.mockData
})
