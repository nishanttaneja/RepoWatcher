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
}

fileprivate extension RepoContributorEntry {
    static let mockData = RepoContributorEntry(date: .now)
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
    private let entry: RepoContributorEntry
    
    init(_ entry: RepoContributorEntry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack {
            Text("\(entry.date.formatted())")
        }
        .containerBackground(for: .widget) { }
    }
}

struct RepoContributorsWidget: Widget {
    let kind = "RepoContributorsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RepoContributorsProvider()) { entry in
            RepoContributorsView(entry)
        }
    }
}

#Preview(as: .systemLarge, widget: {
    RepoContributorsWidget()
}, timeline: {
    RepoContributorEntry.mockData
})
