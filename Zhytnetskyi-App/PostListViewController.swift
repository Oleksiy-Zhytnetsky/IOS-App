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
        static let loadLimit = 15
    }
    
    // MARK: - Properties
    private var posts: [ExtendedPostDetails] = []
    private var afterToken: String?
    private var isLoading: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "r/\(Const.subredditName)"
        loadPosts(limit: Const.loadLimit)
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
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Const.cellReuseId,
            for: indexPath
        ) as! PostTableViewCell
        
        let post = posts[indexPath.row]
        cell.configure(for: post)
        return cell
    }
    
    // MARK: - UIScrollViewDelegate override
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if (offsetY > (contentHeight - height)) {
            loadPosts(limit: Const.loadLimit)
        }
    }
    
    // MARK: - UIViewController override
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Const.detailsSegueId {
            let detailsVC = segue.destination as! PostDetailsViewController
            if let post = sender as? ExtendedPostDetails {
                detailsVC.post = post
            }
            else if let cell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: cell) {
                detailsVC.post = posts[indexPath.row]
            }
        }
    }
    
    // MARK: - Action handlers
    @IBAction func bookmarkBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        Utils.toggleBtnFill(
            sender,
            imgName: "bookmark"
        )
    }

    // MARK: - Private methods
    private func loadPosts(limit: Int) {
        guard (!isLoading) else {
            return
        }
        isLoading = true
        
        Task {
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            do {
                let response = try await PostApiClient.fetchPosts(
                    subreddit: Const.subredditName,
                    limit: limit,
                    after: afterToken
                )
                
                let newPosts = response.data.children.map { child in
                    return ExtendedPostDetails(
                        data: child.data,
                        saved: Bool.random()
                    )
                }
                
                DispatchQueue.main.async {
                    self.afterToken = response.data.after
                    let startIndex = self.posts.count
                    self.posts.append(contentsOf: newPosts)
                    let indexPaths = (startIndex..<self.posts.count).map {
                        IndexPath(row: $0, section: 0)
                    }
                    
                    self.tableView.performBatchUpdates {
                        self.tableView.insertRows(at: indexPaths, with: .automatic)
                    } completion: { _ in
                        if let visibleRows = self.tableView.indexPathsForVisibleRows {
                            self.tableView.reloadRows(at: visibleRows, with: .none)
                        }
                    }
                }

            }
            catch {
                print("Error loading posts: \(error)")
            }
        }
    }
}
