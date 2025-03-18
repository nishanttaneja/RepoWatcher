//
//  Image+Ext.swift
//  RepoWatcher
//
//  Created by Nishant Taneja on 18/03/25.
//

import SwiftUI

extension Image {
    init(contentsOf urlSting: String, placeholderImage: ImageResource) {
        do {
            guard let url = URL(string: urlSting) else { throw URLError(.badURL) }
            let data = try Data(contentsOf: url)
            guard let image = UIImage(data: data) else { throw URLError(.cannotDecodeContentData) }
            self.init(uiImage: image)
        } catch let error {
            debugPrint(#function, error)
            self.init(placeholderImage)
        }
    }
}
