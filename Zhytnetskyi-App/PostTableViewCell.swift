//
//  PostTableViewCell.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 18.03.2025.
//

import UIKit
import SDWebImage

final class PostTableViewCell: UITableViewCell {
    
    // Connect these outlets from your storyboard prototype cell
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeSincePostLabel: UILabel!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var upvoteBtn: UIButton!
    @IBOutlet weak var commentsBtn: UIButton!
    
    // Configure the cell with the post data
    func configure(for post: ExtendedPostDetails) {
        userNameLabel.text = post.data.author_fullname
        timeSincePostLabel.text = Utils.formatTimeSincePost(post.data.created)
        domainLabel.text = post.data.domain
        postTitleLabel.text = post.data.title
        upvoteBtn.setTitle(Utils.formatNumCount(post.data.score), for: .normal)
        commentsBtn.setTitle(Utils.formatNumCount(post.data.num_comments), for: .normal)
        
        if let imageUrl = URL(string: post.data.cleanedUrl) {
            postImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder.png"))
        }
        
        // Set bookmark state and update image
        bookmarkBtn.isSelected = post.saved
        updateBookmarkButton()
    }
    
    @IBAction func bookmarkBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        updateBookmarkButton()
    }
    
    private func updateBookmarkButton() {
        var imgName = "bookmark"
        if bookmarkBtn.isSelected {
            imgName += ".fill"
        }
        bookmarkBtn.setImage(UIImage(systemName: imgName), for: .normal)
    }
}
