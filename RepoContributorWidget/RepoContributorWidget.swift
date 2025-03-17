//
//  RepoContributorWidget.swift
//  RepoContributorWidget
//
//  Created by Nishant Taneja on 17/03/25.
//

import WidgetKit
import SwiftUI

struct RepoContributorProvider: TimelineProvider {
    func placeholder(in context: Context) -> RepoContributorEntry {
        RepoContributorEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (RepoContributorEntry) -> ()) {
        let entry = RepoContributorEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [RepoContributorEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = RepoContributorEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct RepoContributorEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct RepoContributorWidgetEntryView : View {
    var entry: RepoContributorProvider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Emoji:")
            Text(entry.emoji)
        }
    }
}

struct RepoContributorWidget: Widget {
    let kind: String = "RepoContributorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RepoContributorProvider()) { entry in
            if #available(iOS 17.0, *) {
                RepoContributorWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                RepoContributorWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    RepoContributorWidget()
} timeline: {
    RepoContributorEntry(date: .now, emoji: "😀")
    RepoContributorEntry(date: .now, emoji: "🤩")
}
