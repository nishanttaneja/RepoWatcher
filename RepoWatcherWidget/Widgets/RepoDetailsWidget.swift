//
//  RepoDetailsWidget.swift
//  RepoWatcherWidgetExtension
//
//  Created by Nishant Taneja on 17/03/25.
//

import SwiftUI
import WidgetKit

fileprivate struct RepoDetailsEntry: TimelineEntry {
    let date: Date
    let details: RepoDetails
}

fileprivate extension RepoDetailsEntry {
    static let mockData = RepoDetailsEntry(date: .now, details: RepoDetails(ownerImagePath: "", title: "Hello, GitHub", daysSinceLastActivity: 5, watchers: 9, forks: 3, issues: 2, contributors: []))
}

fileprivate struct RepoDetailsProvider: TimelineProvider {
    typealias Entry = RepoDetailsEntry
    
    func placeholder(in context: Context) -> RepoDetailsEntry {
        .mockData
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (RepoDetailsEntry) -> Void) {
        completion(.mockData)
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<RepoDetailsEntry>) -> Void) {
        let timeline: Timeline<RepoDetailsEntry> = Timeline(entries: [.mockData], policy: .after(.now))
        completion(timeline)
    }
}

struct RepoDetailsView: View {
    private let details: RepoDetails
    
    init(_ details: RepoDetails) {
        self.details = details
    }
    
    var body: some View {
        VStack {
            Text(details.title)
        }
        .containerBackground(for: .widget) { }
    }
}

struct RepoDetailsWidget: Widget {
    private let kind = "RepoDetailsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RepoDetailsProvider()) { entry in
            RepoDetailsView(entry.details)
        }
        .configurationDisplayName("Repo Watcher")
        .description("Keep an eye on a GitHub repository.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium, widget: {
    RepoDetailsWidget()
}, timeline: {
    RepoDetailsEntry.mockData
})
