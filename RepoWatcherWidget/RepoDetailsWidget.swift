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
    let details: RepoDetails
}

extension RepoDetailsEntry {
    static let placeholderData = RepoDetailsEntry(date: .now, details: RepoDetails(ownerImagePath: "", title: "Hello, GitHub", description: "There's no description available for this repository.", daysSinceLastActivity: 5, watchers: 9, forks: 3, issues: 2, contributors: [
        RepoDetails.Contributor(userImagePath: "", username: "username", contributions: 6),
        RepoDetails.Contributor(userImagePath: "", username: "username", contributions: 5),
        RepoDetails.Contributor(userImagePath: "", username: "username", contributions: 4),
        RepoDetails.Contributor(userImagePath: "", username: "username", contributions: 3)
    ]))
    static let mockData = RepoDetailsEntry(date: .now, details: RepoDetails(ownerImagePath: "", title: "Real-Dicee", description: "An iOS Application using ARKit and SCNKit to display Dice in Real World.", daysSinceLastActivity: 1648, watchers: 2, forks: 0, issues: 0, contributors: [
        RepoDetails.Contributor(userImagePath: "", username: "nishanttaneja", contributions: 10)
    ]))
}

fileprivate struct RepoDetailsProvider: AppIntentTimelineProvider {
    typealias Entry = RepoDetailsEntry
    typealias Intent = SelectRepoAppIntent
    
    func placeholder(in context: Context) -> RepoDetailsEntry {
        .mockData
    }
    
    func snapshot(for configuration: SelectRepoAppIntent, in context: Context) async -> RepoDetailsEntry {
        .mockData
    }
    
    func timeline(for configuration: SelectRepoAppIntent, in context: Context) async -> Timeline<RepoDetailsEntry> {
        var repoDetails: RepoDetails
        do {
            let repository = configuration.repository ?? URLSession.defaultRepository
            repoDetails = try await URLSession.getRepoDetails(for: repository) ?? .mockData
            let contributors = try await URLSession.getRepoContributors(for: repository)
            repoDetails.setContributors(contributors)
        } catch {
            debugPrint(#function, error)
            repoDetails = .mockData
        }
        let timeline: Timeline<RepoDetailsEntry> = Timeline(entries: [RepoDetailsEntry(date: .now, details: repoDetails)], policy: .never)
        return timeline
    }
}

fileprivate struct RepoDetailsView: View {
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
                        .widgetAccentedRenderingMode(.desaturated)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                        .contentTransition(.opacity)
                    Text(details.title)
                        .font(.title2)
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.7)
                        .widgetAccentable()
                        .contentTransition(.opacity)
                }
                Spacer().frame(height: 8)
                if details.description.isEmpty == false {
                    Text(details.description)
                        .font(.caption)
                        .fontWeight(.light)
                        .lineLimit(4)
                        .foregroundStyle(.secondary)
                        .contentTransition(.opacity)
                    Spacer().frame(height: 8)
                }
                HStack {        // Repo details: forks, watchers, issues
                    Label {
                        Text("\(details.watchers)")
                            .font(.caption)
                            .contentTransition(.numericText())
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.green)
                    }
                    Label {
                        Text("\(details.forks)")
                            .font(.caption)
                            .contentTransition(.numericText())
                    } icon: {
                        Image(systemName: "tuningfork")
                            .foregroundStyle(.green)
                    }
                    if details.issues > .zero {
                        Label {
                            Text("\(details.issues)")
                                .font(.caption)
                                .contentTransition(.numericText())
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .widgetAccentable()
            }
            Spacer(minLength: 8)
            VStack(alignment: .center, spacing: -8) {        // Days since last activity
                Text("\(details.daysSinceLastActivity)")
                    .font(.system(size: 64, weight: .bold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundStyle(details.daysSinceLastActivity > 50 ? .red : .green)
                    .frame(maxWidth: 108)
                    .widgetAccentable()
                    .contentTransition(.numericText())
                Text("days ago")
                    .font(.caption2)
                    .fontWeight(.light)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(for: .widget) { }
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

fileprivate struct RepoDetailsWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    private let details: RepoDetails
    
    init(_ details: RepoDetails) {
        self.details = details
    }
    
    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            RepoDetailsView(details)
        case .systemLarge:
            RepoContributorsView(details)
        default:
            Text("unsupported widget family")
        }
    }
}

@main
fileprivate struct RepoDetailsWidget: Widget {
    private let kind = "RepoDetailsWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectRepoAppIntent.self, provider: RepoDetailsProvider()) { entry in
            RepoDetailsWidgetView(entry.details)
        }
        .configurationDisplayName("Repo Watcher")
        .description("Keep an eye on a GitHub repository.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium, widget: {
    RepoDetailsWidget()
}, timeline: {
    RepoDetailsEntry.placeholderData
    RepoDetailsEntry.mockData
})
#Preview(as: .systemLarge, widget: {
    RepoDetailsWidget()
}, timeline: {
    RepoDetailsEntry.placeholderData
    RepoDetailsEntry.mockData
})
