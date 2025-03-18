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
    static let placeholderData = RepoContributorEntry(date: .now, details: RepoDetails(ownerImagePath: "", title: "Repository", description: "There's no description available for this repository.", daysSinceLastActivity: 5, watchers: 9, forks: 3, issues: 2, contributors: [
        RepoDetails.Contributor(userImagePath: "", username: "username", contributions: 6),
        RepoDetails.Contributor(userImagePath: "", username: "username", contributions: 5),
        RepoDetails.Contributor(userImagePath: "", username: "username", contributions: 4),
        RepoDetails.Contributor(userImagePath: "", username: "username", contributions: 3)
    ]))
    static let mockData = RepoContributorEntry(date: .now, details: RepoDetails(ownerImagePath: "", title: "Real-Dicee", description: "An iOS Application using ARKit and SCNKit to display Dice in Real World.", daysSinceLastActivity: 1648, watchers: 2, forks: 0, issues: 0, contributors: [
        RepoDetails.Contributor(userImagePath: "", username: "nishanttaneja", contributions: 10)
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
                repoDetails = try await URLSession.getRepoDetails() ?? .mockData
                let repoContributors = try await URLSession.getRepoContributors()
                repoDetails.setContributors(repoContributors)
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
            Spacer().frame(height: 8)
            Rectangle()
                .fill(.thinMaterial)
                .frame(height: 1)
            if details.contributors.count > .zero {
                Spacer().frame(height: 8)
                Text("Top Contributors")         // Contributors List View
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), alignment: .leading, spacing: 8) {
                    ForEach(details.contributors) { contributor in
                            HStack {        // Image and title
                                Image(contentsOf: contributor.userImagePath, placeholderImage: .avatar)
                                    .resizable()
                                    .widgetAccentedRenderingMode(.desaturated)
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                                VStack(alignment: .leading) {
                                    Text(contributor.username)
                                        .font(.caption)
                                        .minimumScaleFactor(0.8)
                                        .lineLimit(1)
                                        .widgetAccentable()
                                        .contentTransition(.opacity)
                                    Text("\(contributor.contributions)")
                                        .font(.caption)
                                        .fontWeight(.light)
                                        .foregroundStyle(.secondary)
                                        .minimumScaleFactor(0.7)
                                        .contentTransition(.numericText())
                                }
                            }
                    }
                }
            }
            Spacer()
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
    RepoContributorEntry.placeholderData
    RepoContributorEntry.mockData
})
