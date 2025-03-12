//
//  PostApiClient.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 12.03.2025.
//

import Foundation

class PostApiClient {
    
    static func fetchPosts(
        subreddit: String,
        limit: Int = 1,
        after: String? = nil
    ) async throws -> ApiResponse {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.reddit.com"
        components.path = "/r/\(subreddit)/top.json"
        
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        if let after = after {
            queryItems.append(URLQueryItem(name: "after", value: "\(after)"))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        let (resp, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        return try decoder.decode(ApiResponse.self, from: resp)
    }
    
}
