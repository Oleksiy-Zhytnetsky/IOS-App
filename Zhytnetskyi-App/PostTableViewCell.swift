//
//  PostTableViewCell.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 18.03.2025.
//

import UIKit
import SDWebImage

final class PostTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var timeSincePostLabel: UILabel!
    @IBOutlet private weak var domainLabel: UILabel!
    @IBOutlet private weak var postTitleLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var bookmarkBtn: UIButton!
    @IBOutlet private weak var upvoteBtn: UIButton!
    @IBOutlet private weak var commentsBtn: UIButton!
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        userNameLabel.text = nil
        timeSincePostLabel.text = nil
        domainLabel.text = nil
        postTitleLabel.text = nil
        postImageView.image = nil
        disableBookmarkBtn(bookmarkBtn)
    }
    
    // MARK: - Public methods
    func configure(for post: ExtendedPostDetails) {
        DispatchQueue.main.async {
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
                placeholderImage: UIImage(named: "placeholder")
            )
            
            if (post.saved) {
                self.enableBookmarkBtn(self.bookmarkBtn)
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
    private func enableBookmarkBtn(_ btn: UIButton) {
        btn.isSelected = true
        btn.setImage(
            UIImage(systemName: "bookmark.fill"),
            for: .normal
        )
    }
    
    private func disableBookmarkBtn(_ btn: UIButton) {
        btn.isSelected = false
        btn.setImage(
            UIImage(systemName: "bookmark"),
            for: .normal
        )
    }
    
}
