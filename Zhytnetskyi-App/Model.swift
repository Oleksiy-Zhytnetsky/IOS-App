//
//  Model.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 11.03.2025.
//

import Foundation

struct ExtendedPostDetails {
    let data: PostDetails
    let saved: Bool
}

struct ApiResponse : Codable {
    let data: PostPaginatedInfo
}

struct PostPaginatedInfo : Codable {
    let after: String?
    let before: String?
    let children: [PostData]
}

struct PostData : Codable {
    let data: PostDetails
}

struct PostDetails : Codable {
    let author_fullname: String
    let domain: String
    let title: String
    let num_comments: Int
    let score: Int
    let selftext: String
    let url: String // raw img url
    let created: TimeInterval // unix timestamp
    let permalink: String
    
    var cleanedUrl: String {
        return url.replacingOccurrences(of: "&amp;", with: "&")
    }
    
    var postUrl: String {
        return "https://www.reddit.com" + permalink
    }
}
