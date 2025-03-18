//
//  ContentView.swift
//  RepoWatcher
//
//  Created by Nishant Taneja on 17/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var newRepository = ""
    @State private var repositories: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Ex. \(URLSession.defaultRepository)", text: $newRepository)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    Button {
                        if !newRepository.replacingOccurrences(of: " ", with: "").isEmpty,
                           !repositories.contains(newRepository) {
                            repositories.append(newRepository)
                            newRepository = ""
                            UserDefaults.shared?.repositories = repositories
                        } else {
                            debugPrint(#function, "repository already exists or is invalid")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.green)
                    }
                }
                .padding()
                VStack(alignment: .leading) {
                    Text("Saved Repositories:")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.leading)
                    List(repositories, id: \.self) { repo in
                        Text(repo)
                            .swipeActions {
                                Button("Delete") {
                                    guard repositories.count > 1 else { return }
                                    repositories.removeAll(where: { $0 == repo })
                                    UserDefaults.shared?.repositories = repositories
                                }
                                .tint(.red)
                            }
                    }
                }
            }
            .navigationTitle("Repositories")
            .onAppear {
                if let savedRepositories = UserDefaults.shared?.repositories, !savedRepositories.isEmpty {
                    repositories = savedRepositories
                } else {
                    repositories = [URLSession.defaultRepository]
                    UserDefaults.shared?.repositories = repositories
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
