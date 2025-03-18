//
//  URLSession+Ext.swift
//  RepoWatcher
//
//  Created by Nishant Taneja on 18/03/25.
//

import Foundation

extension URLSession {
    func data<T: Decodable>(ofType decodingDataType: T.Type, from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await data(from: url)
        return try JSONDecoder.shared.decode(decodingDataType.self, from: data)
    }
}

fileprivate extension JSONDecoder {
    static let shared: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
