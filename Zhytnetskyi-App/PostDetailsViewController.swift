//
//  PostDetailsViewController.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 18.03.2025.
//

import UIKit
import SDWebImage

private typealias PostListConst = PostListViewController.Const

final class PostDetailsViewController: UIViewController {
    
    // MARK: - Properties
    private var post: ExtendedPostDetails!
    
    // MARK: - Outlets
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var timeSincePostLabel: UILabel!
    @IBOutlet private weak var domainLabel: UILabel!
    @IBOutlet private weak var postTitleLabel: UILabel!
    @IBOutlet private weak var postDescriptionLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var bookmarkBtn: UIButton!
    @IBOutlet private weak var upvoteBtn: UIButton!
    @IBOutlet private weak var commentsBtn: UIButton!
    @IBOutlet private weak var shareBtn: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.userNameLabel.text = self.post.data.author_fullname
            self.timeSincePostLabel.text = Utils.formatTimeSincePost(
                self.post.data.created
            )
            self.domainLabel.text = self.post.data.domain
            self.postTitleLabel.text = self.post.data.title
            self.postDescriptionLabel.text = self.post.data.selftext
            self.upvoteBtn.setTitle(
                Utils.formatNumCount(self.post.data.score),
                for: .normal
            )
            self.commentsBtn.setTitle(
                Utils.formatNumCount(self.post.data.num_comments),
                for: .normal
            )
            self.postImageView.sd_setImage(
                with: URL(string: self.post.data.cleanedUrl),
                placeholderImage: UIImage(named: "placeholder")
            )
            
            if (self.post.saved) {
                Utils.enableBtnFill(
                    self.bookmarkBtn,
                    imgName: "bookmark"
                )
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
        
        self.post.saved = sender.isSelected
        NotificationCenter.default.post(
            name: NSNotification.Name(PostListConst.postSavedNotificationId),
            object: nil,
            userInfo: [
                "permalink": self.post.data.permalink,
                "saved": self.post.saved
            ]
        )
        SavedPostsManager.shared.updatePost(self.post)
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        guard let postUrl = URL(string: self.post.data.postUrl) else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [postUrl],
            applicationActivities: nil
        )
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - Selectors & Modifiers
    func setPost(_ newPost: ExtendedPostDetails) {
        self.post = newPost
    }
}
