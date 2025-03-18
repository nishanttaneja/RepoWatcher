//
//  SelectRepoAppIntent.swift
//  RepoWatcherWidgetExtension
//
//  Created by Nishant Taneja on 19/03/25.
//

import AppIntents
import WidgetKit

struct SelectRepoAppIntent: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Repo"
    static var description: IntentDescription? = .init(stringLiteral: "Select a repo to display details.")
    
    @Parameter(title: "Repository", optionsProvider: SelectRepoOptionsProvider()) private(set) var repository: String?
    
    fileprivate struct SelectRepoOptionsProvider: DynamicOptionsProvider {
        typealias Result = [String]
        
        func results() async throws -> [String] {
            UserDefaults.shared?.repositories ?? [URLSession.defaultRepository]
        }
        
        func defaultResult() async -> String? {
            URLSession.defaultRepository
        }
    }
}
