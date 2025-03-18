//
//  PostDetailsViewController.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 18.03.2025.
//

import UIKit
import SDWebImage

final class PostDetailsViewController: UIViewController {
    
    // Variable to receive the selected post data
    var post: ExtendedPostDetails?
    
    // Connect these outlets from your storyboard scene
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeSincePostLabel: UILabel!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel! // Additional details
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Safely unwrap post data
        guard let post = post else { return }
        userNameLabel.text = post.data.author_fullname
        timeSincePostLabel.text = Utils.formatTimeSincePost(post.data.created)
        domainLabel.text = post.data.domain
        postTitleLabel.text = post.data.title
        
        // For example, show more details in descriptionLabel. Update this as needed.
        descriptionLabel.text = "Here is a detailed view of the post."
        
        if let imageUrl = URL(string: post.data.cleanedUrl) {
            postImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder.png"))
        }
    }
}
