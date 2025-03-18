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
    static let mockData = RepoDetailsEntry(date: .now, details: RepoDetails(ownerImagePath: "", title: "Hello, GitHub", description: "There's no description available for this repository.", daysSinceLastActivity: 5, watchers: 9, forks: 3, issues: 2, contributors: []))
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
        Task {
            let repoDetails: RepoDetails
            do {
                repoDetails = try await URLSession.getRepoDetails() ?? .mockData
            } catch {
                debugPrint(#function, error)
                repoDetails = .mockData
            }
            let timeline: Timeline<RepoDetailsEntry> = Timeline(entries: [RepoDetailsEntry(date: .now, details: repoDetails)], policy: .never)
            completion(timeline)
        }
    }
}

struct RepoDetailsView: View {
    private let details: RepoDetails
    
    init(_ details: RepoDetails) {
        self.details = details
    }
    
    var body: some View {
        HStack {        // Main content view
            VStack(alignment: .leading) {        // Left view: content excluding days since last activity
                HStack {        // Image and title
                    Image(contentsOf: details.ownerImagePath, placeholderImage: .avatar)
                        .resizable()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                    Text(details.title)
                        .font(.title2)
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.7)
                }
                Spacer().frame(height: 8)
                if details.description.isEmpty == false {
                    Text(details.description)
                        .font(.caption)
                        .fontWeight(.light)
                        .lineLimit(4)
                        .foregroundStyle(.secondary)
                    Spacer().frame(height: 8)
                }
                HStack {        // Repo details: forks, watchers, issues
                    Label {
                        Text("\(details.watchers)")
                            .font(.caption)
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.green)
                    }
                    Label {
                        Text("\(details.forks)")
                            .font(.caption)
                    } icon: {
                        Image(systemName: "tuningfork")
                            .foregroundStyle(.green)
                    }
                    if details.issues > .zero {
                        Label {
                            Text("\(details.issues)")
                                .font(.caption)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            Spacer(minLength: 8)
            VStack(alignment: .center, spacing: -8) {        // Days since last activity
                Text("\(details.daysSinceLastActivity)")
                    .font(.system(size: 64, weight: .bold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundStyle(details.daysSinceLastActivity > 50 ? .red : .green)
                Text("days ago")
                    .font(.caption2)
                    .fontWeight(.light)
                    .foregroundStyle(.secondary)
            }
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
