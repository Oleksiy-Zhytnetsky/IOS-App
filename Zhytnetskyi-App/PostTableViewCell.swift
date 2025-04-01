//
//  PostTableViewCell.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 18.03.2025.
//

import UIKit
import SDWebImage

private typealias PostListConst = PostListViewController.Const

final class PostTableViewCell : UITableViewCell {
    
    // MARK: - Const
    private enum Const {
        static let placeholderImageName = "placeholder"
    }
    
    // MARK: - Properties
    private var post: ExtendedPostDetails?
    
    // MARK: - Outlets
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var timeSincePostLabel: UILabel!
    @IBOutlet private weak var domainLabel: UILabel!
    @IBOutlet private weak var postTitleLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var bookmarkBtn: UIButton!
    @IBOutlet private weak var upvoteBtn: UIButton!
    @IBOutlet private weak var commentsBtn: UIButton!
    @IBOutlet private weak var shareBtn: UIButton!
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        self.post = nil
        self.userNameLabel.text = nil
        self.timeSincePostLabel.text = nil
        self.domainLabel.text = nil
        self.postTitleLabel.text = nil
        self.postImageView.image = nil
        Utils.disableBtnFill(
            self.bookmarkBtn,
            imgName: "bookmark"
        )
    }
    
    // MARK: - Public methods
    func configure(for post: ExtendedPostDetails) {
        DispatchQueue.main.async {
            self.post = post
            self.userNameLabel.text = post.data.author_fullname
            self.timeSincePostLabel.text = Utils.formatTimeSincePost(
                post.data.created
            )
            self.domainLabel.text = post.data.domain
            self.postTitleLabel.text = post.data.title
            self.upvoteBtn.setTitle(
                Utils.formatNumCount(post.data.score),
                for: .normal
            )
            self.commentsBtn.setTitle(
                Utils.formatNumCount(post.data.num_comments),
                for: .normal
            )
            
            self.postImageView.sd_setImage(
                with: URL(string: post.data.cleanedUrl),
                placeholderImage: UIImage(named: Const.placeholderImageName)
            )
            
            if (post.saved) {
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
        
        guard var post = self.post else {
            return
        }
        post.saved = sender.isSelected
        self.post = post
        
        NotificationCenter.default.post(
            name: NSNotification.Name(PostListConst.postSavedNotificationId),
            object: nil,
            userInfo: [
                "permalink": post.data.permalink,
                "saved": post.saved
            ]
        )
        SavedPostsManager.shared.updatePost(post)
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        guard let post = self.post,
              let postUrl = URL(string: post.data.postUrl) else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [postUrl],
            applicationActivities: nil
        )
        if let parentVC = self.parentViewController {
            parentVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Extensions
extension UIView {
    // MARK: - Properties
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
