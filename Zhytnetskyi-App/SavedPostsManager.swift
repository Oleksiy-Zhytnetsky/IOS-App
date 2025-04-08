//
//  SavedPostsManager.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 01.04.2025.
//

import Foundation

final class SavedPostsManager {
    
    // MARK: - Shared instance
    static let shared = SavedPostsManager()
    
    
    // MARK: - Const
    private enum Const {
        static let filename = "savedPosts.json"
    }
    
    // MARK: - Properties
    private var savedPosts: [ExtendedPostDetails] = []
    
    private var fileUrl: URL {
        let docsUrl = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        return docsUrl.appendingPathComponent(Const.filename)
    }
    
    // MARK: - Lifetime
    private init() {
        self.savedPosts = loadSavedPosts()
    }
    
    // MARK: - Public Methods
    func loadSavedPosts() -> [ExtendedPostDetails] {
        guard let data = try? Data(contentsOf: self.fileUrl) else {
            return []
        }
        
        let decoder = JSONDecoder()
        if let posts = try? decoder.decode([ExtendedPostDetails].self, from: data) {
            return posts
        }
        return []
    }
    
    func updatePost(_ post: ExtendedPostDetails) {
        if post.saved {
            if !self.savedPosts.contains(where: { $0.data.permalink == post.data.permalink }) {
                self.savedPosts.append(post)
            }
        }
        else {
            savedPosts.removeAll(where: { $0.data.permalink == post.data.permalink })
        }
        saveAll()
    }
    
    func isPostSaved(permalink: String) -> Bool {
        return self.savedPosts.contains(where: { $0.data.permalink == permalink })
    }
        
    func getAllSavedPosts() -> [ExtendedPostDetails] {
        return self.savedPosts.reversed()
    }
    
    // MARK: - Private Methods
    private func saveAll() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(savedPosts) {
            try? data.write(to: self.fileUrl)
        }
    }
}
