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
}

fileprivate extension RepoDetailsEntry {
    static let mockData = RepoDetailsEntry(date: .now)
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

fileprivate struct RepoDetailsView: View {
    private let entry: RepoDetailsEntry
    
    init(_ entry: RepoDetailsEntry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack {
            Text("\(entry.date.formatted(date: .long, time: .complete))")
        }
        .containerBackground(for: .widget) { }
    }
}

struct RepoDetailsWidget: Widget {
    private let kind = "RepoDetailsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RepoDetailsProvider()) { entry in
            RepoDetailsView(entry)
        }
    }
}

#Preview(as: .systemMedium, widget: {
    RepoDetailsWidget()
}, timeline: {
    RepoDetailsEntry.mockData
})
