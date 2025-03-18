//
//  UserDefaults+Ext.swift
//  RepoWatcher
//
//  Created by Nishant Taneja on 19/03/25.
//

import Foundation

extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.dev.unkn0wny3t-ios.repowatcher")
}

extension UserDefaults {
    private static let kRepositories = "repositories"
    var repositories: [String] {
        get {
            array(forKey: Self.kRepositories) as? [String] ?? []
        }
        set {
            setValue(newValue, forKey: Self.kRepositories)
        }
    }
}
