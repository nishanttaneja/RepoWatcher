//
//  RepoDetailsWidget.swift
//  RepoWatcherWidgetExtension
//
//  Created by Nishant Taneja on 17/03/25.
//

import SwiftUI
import WidgetKit

struct RepoDetailsEntry: TimelineEntry {
    let date: Date
}

extension RepoDetailsEntry {
    static let mockData = RepoDetailsEntry(date: .now)
}

struct RepoDetailsProvider: TimelineProvider {
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
    let repoDetailsEntry: RepoDetailsEntry
    
    var body: some View {
        VStack {
            Text("\(repoDetailsEntry.date.formatted(date: .long, time: .complete))")
        }
        .containerBackground(for: .widget) { }
    }
}

struct RepoDetailsWidget: Widget {
    let kind = "RepoDetailsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RepoDetailsProvider()) { entry in
            RepoDetailsView(repoDetailsEntry: entry)
        }
    }
}

#Preview(as: .systemMedium, widget: {
    RepoDetailsWidget()
}, timeline: {
    RepoDetailsEntry.mockData
})
