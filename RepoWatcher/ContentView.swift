//
//  ContentView.swift
//  RepoWatcher
//
//  Created by Nishant Taneja on 17/03/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Checkout Widget!")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Keep an eye on GitHub repository.")
                .font(.callout)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
