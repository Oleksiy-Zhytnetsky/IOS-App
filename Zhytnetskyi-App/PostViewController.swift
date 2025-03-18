//
//  PostViewController.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 11.03.2025.
//

import UIKit
import SDWebImage

final class PostViewController: UIViewController {
    
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var timeSincePostLabel: UILabel!
    @IBOutlet private weak var domainLabel: UILabel!
    @IBOutlet private weak var postTitleLabel: UILabel!
    @IBOutlet private weak var bookmarkBtn: UIButton!
    @IBOutlet private weak var upvoteBtn: UIButton!
    @IBOutlet private weak var commentsBtn: UIButton!
    @IBOutlet private weak var postImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let resp = try await PostApiClient.fetchPosts(
                    subreddit: "ios"
                )
                
                guard let postData = resp.data.children.first else {
                    print("Error: No post available")
                    return
                }
                let post = ExtendedPostDetails(
                    data: postData.data,
                    saved: Bool.random()
                )
                
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
                        Utils.toggleBtnFill(
                            self.bookmarkBtn,
                            imgName: "bookmark"
                        )
                    }
                }
            }
            catch {
                print("Error fetching posts: \(error)")
            }
        }
    }
    
    @IBAction
    func bookmarkBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        Utils.toggleBtnFill(
            sender,
            imgName: "bookmark"
        )
    }
    
}
