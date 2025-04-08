//
//  PostListViewController.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 18.03.2025.
//

import UIKit

final class PostListViewController : UITableViewController, UITextFieldDelegate {
    
    // MARK: - Const
    enum Const {
        static let subredditName = "ios"
        static let loadLimit = 15
        
        static let cellReuseId = "PostTableCell"
        static let postSavedNotificationId = "PostSavedStatusChanged"
        static let postDetailsVCId = "PostDetailsViewController"
        
        static let bookmarkAnimHalfDuration = 0.35
        static let bookmarkAnimFadeDelay = 0.1
        static let bookmarkAnimFadeDeadline = bookmarkAnimHalfDuration + bookmarkAnimFadeDelay
    }
    
    // MARK: - Properties
    private var posts: [ExtendedPostDetails] = []
    private var allSavedPosts: [ExtendedPostDetails] = []
    private var afterToken: String?
    private var isLoading: Bool = false
    private var isOfflineMode: Bool = false
    
    // MARK: - Outlets
    @IBOutlet private weak var appModeBtn: UIButton!
    @IBOutlet private weak var searchTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "r/\(Const.subredditName)"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onPostSavedStatusChanged),
            name: NSNotification.Name(Const.postSavedNotificationId),
            object: nil
        )
        
        self.appModeBtn.isSelected = false
        self.searchTextField.delegate = self
        self.searchTextField.addTarget(
            self,
            action: #selector(onSearchTextChanged),
            for: .editingChanged
        )
        self.searchTextField.isHidden = true
        
        loadPosts(limit: Const.loadLimit)
    }
    
    // MARK: - UITableViewDataSource override
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return self.posts.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Const.cellReuseId,
            for: indexPath
        ) as! PostTableViewCell
        
        let post = self.posts[indexPath.row]
        cell.configure(for: post)
        cell.delegate = self
        return cell
    }
    
    // MARK: - UIScrollViewDelegate override
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if (offsetY > (contentHeight - height * 3)) {
            loadPosts(limit: Const.loadLimit)
        }
    }
    
    // MARK: - UITextFieldDelegate override
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Action handlers
    @IBAction func appModeBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        Utils.toggleBtnFill(
            sender,
            imgName: "bookmark"
        )
        self.isOfflineMode = sender.isSelected
        
        if (isOfflineMode) {
            self.allSavedPosts = SavedPostsManager.shared.getAllSavedPosts()
            self.posts = self.allSavedPosts
            self.tableView.reloadData()
            
            self.searchTextField.isHidden = false
            self.searchTextField.isUserInteractionEnabled = true
        }
        else {
            self.searchTextField.isHidden = true
            self.searchTextField.isUserInteractionEnabled = false
            self.searchTextField.text = ""
            
            self.posts.removeAll()
            self.afterToken = nil
            tableView.reloadData()
            loadPosts(limit: Const.loadLimit)
        }
    }
    
    @objc
    private func onPostSavedStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let permalink = userInfo["permalink"] as? String,
              let saved = userInfo["saved"] as? Bool else {
            return
        }
        
        if let index = self.posts.firstIndex(where: { $0.data.permalink == permalink }) {
            self.posts[index].saved = saved
            let indexPath = IndexPath(row: index, section: 0)
            if self.isOfflineMode && !saved {
                self.posts.remove(at: index)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                allSavedPosts.removeAll(where: { $0.data.permalink == permalink })
            }
            else {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    @objc
    private func onSearchTextChanged(_ textField: UITextField) {
        guard (self.isOfflineMode) else {
            return
        }
        
        let filterQuery = textField.text
        if (filterQuery != nil && !(filterQuery!.isEmpty)) {
            let query = filterQuery!.lowercased()
            self.posts = self.allSavedPosts.filter {
                $0.data.title.lowercased().contains(query)
            }
        }
        else {
            self.posts = self.allSavedPosts
        }
        
        tableView.reloadData()
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
                    let isSaved = SavedPostsManager.shared.isPostSaved(
                        permalink: child.data.permalink
                    )
                    return ExtendedPostDetails(
                        data: child.data,
                        saved: isSaved
                    )
                }
                
                if (!self.isOfflineMode) {
                    DispatchQueue.main.async {
                        self.afterToken = response.data.after
                        let startIndex = self.posts.count
                        self.posts.append(contentsOf: newPosts)
                        let indexPaths = (startIndex..<self.posts.count).map {
                            IndexPath(row: $0, section: 0)
                        }
                        
                        self.tableView.performBatchUpdates {
                            self.tableView.insertRows(
                                at: indexPaths,
                                with: .automatic
                            )
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

extension PostListViewController : PostTableViewCellDelegate {
    func postTableViewCellDidTap(_ cell: PostTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        let post = self.posts[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postDetailsVC = storyboard.instantiateViewController(
            withIdentifier: Const.postDetailsVCId
        ) as! PostDetailsViewController
        
        postDetailsVC.setPost(post)
        self.navigationController?.pushViewController(
            postDetailsVC,
            animated: true
        )
    }
}
