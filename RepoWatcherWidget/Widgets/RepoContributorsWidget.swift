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
    static let mockData = RepoContributorEntry(date: .now, details: RepoDetails(ownerImagePath: "", title: "Hello, GitHub", daysSinceLastActivity: 5, watchers: 9, forks: 3, issues: 2, contributors: [
        RepoDetails.Contributor(userImagePath: "", username: "C-1", contributions: 6),
        RepoDetails.Contributor(userImagePath: "", username: "C-2", contributions: 5),
        RepoDetails.Contributor(userImagePath: "", username: "C-3", contributions: 4),
        RepoDetails.Contributor(userImagePath: "", username: "C-4", contributions: 3),
        RepoDetails.Contributor(userImagePath: "", username: "C-5", contributions: 2),
        RepoDetails.Contributor(userImagePath: "", username: "C-6", contributions: 1),
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
        let timeline: Timeline<RepoContributorEntry> = Timeline(entries: [.mockData], policy: .after(.now))
        completion(timeline)
    }
}

fileprivate struct RepoContributorsView: View {
    private let details: RepoDetails
    
    init(_ details: RepoDetails) {
        self.details = details
    }
    
    var body: some View {
        VStack {
            RepoDetailsView(details)        // Repo Details
            Text(details.title)         // Contributors List View
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
