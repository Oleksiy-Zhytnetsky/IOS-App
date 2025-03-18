//
//  PostListViewController.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 18.03.2025.
//

import UIKit

final class PostListViewController: UITableViewController {
    
    // MARK: - Const
    private struct Const {
        static let subredditName = "ios"
        static let cellReuseId = "PostTableCell"
        static let detailsSegueId = "ShowDetailsSegue"
    }
    
    // MARK: - Properties
    private var posts: [ExtendedPostDetails] = []
    private var afterToken: String?
    private var isLoading = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "r/\(Const.subredditName)"
        
        tableView.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: Const.cellReuseId
        )
        loadPosts(limit: 10)
    }
    
    // MARK: - UITableViewDataSource override
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return posts.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Const.cellReuseId,
            for: indexPath
        ) as? PostTableViewCell else {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        cell.configure(for: post)
        return cell
    }
    
    // MARK: - UITableViewDelegate override
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let post = posts[indexPath.row]
        performSegue(withIdentifier: Const.detailsSegueId, sender: post)
    }
    
    // MARK: - UIScrollViewDelegate override
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if (offsetY > (contentHeight - height - 100)) {
            loadPosts(limit: 10)
        }
    }
    
    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.identifier {
//        case Const.detailsSegueId:
//            let detailsVC = segue.destination as! PostDetailsViewController
//            let post = sender as! ExtendedPostDetails
//            detailsVC.post = post
//
//        default: break
//        }
//    }

    // MARK: - Private methods
    private func loadPosts(limit: Int) {
        guard !isLoading else {
            return
        }
        isLoading = true
        
        Task {
            do {
                let response = try await PostApiClient.fetchPosts(
                    subreddit: Const.subredditName,
                    limit: limit,
                    after: afterToken
                )
                
                // Map the API response to our model
                let newPosts = response.data.children.map { child in
                    return ExtendedPostDetails(
                        data: child.data,
                        saved: Bool.random()
                    )
                }
                // Update pagination token from the response
                self.afterToken = response.data.after
                
                // Append new posts and reload table view on the main thread
                DispatchQueue.main.async {
                    self.posts.append(contentsOf: newPosts)
                    self.tableView.reloadData()
                }
            } catch {
                print("Error loading posts: \(error)")
            }
            self.isLoading = false
        }
    }
}
