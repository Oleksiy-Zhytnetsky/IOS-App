//
//  PostDetailsViewController.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 18.03.2025.
//

import UIKit
import SDWebImage

private typealias PostListConst = PostListViewController.Const

final class PostDetailsViewController : UIViewController {
    
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
    @IBOutlet private weak var bookmarkAnimView: UIView!
    
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
            
            self.bookmarkAnimView.isHidden = true
            RenderUtils.drawBookmark(view: self.bookmarkAnimView)
            let saveGestureRecogniser = UITapGestureRecognizer(
                target: self,
                action: #selector(self.onImageDoubleTapped)
            )
            saveGestureRecogniser.numberOfTapsRequired = 2
            self.view.addGestureRecognizer(saveGestureRecogniser)
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
        SavedPostsManager.shared.updatePost(self.post)
        notifyOnSaved(post: self.post)
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
    
    @objc
    private func onImageDoubleTapped(_ gestureRecogniser: UIGestureRecognizer) {
        let tapLocation = gestureRecogniser.location(in: self.view)
        if self.postImageView.bounds.contains(
            self.postImageView.convert(tapLocation, from: self.view)
        ) {
            guard var post = self.post else {
                return
            }
            
            if (!post.saved) {
                Utils.enableBtnFill(
                    self.bookmarkBtn,
                    imgName: "bookmark"
                )

                post.saved = true
                SavedPostsManager.shared.updatePost(post)
                
                animateSave()
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + PostListConst.bookmarkAnimFadeDeadline
                ) {
                    self.animateSave()
                    self.notifyOnSaved(post: post) // deferred due to cell reload
                }
            }
            else {
                animateSave()
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + PostListConst.bookmarkAnimFadeDeadline,
                    execute: animateSave
                )
            }
        }
    }
    
    // MARK: - Private methods
    private func notifyOnSaved(post: ExtendedPostDetails) {
        NotificationCenter.default.post(
            name: NSNotification.Name(PostListConst.postSavedNotificationId),
            object: nil,
            userInfo: [
                "permalink": post.data.permalink,
                "saved": post.saved
            ]
        )
    }
    
    private func animateSave() {
        UIView.transition(
            with: self.view,
            duration: PostListConst.bookmarkAnimHalfDuration,
            options: .transitionCrossDissolve
        ) {
            self.bookmarkAnimView.isHidden = !self.bookmarkAnimView.isHidden
        }
    }
    
    // MARK: - Selectors & Modifiers
    func setPost(_ newPost: ExtendedPostDetails) {
        self.post = newPost
    }
}
