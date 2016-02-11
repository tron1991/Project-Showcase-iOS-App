//
//  PostCell.swift
//  Project-Showcase
//
//  Created by Nick on 2016-02-07.
//  Copyright © 2016 Nicholas Ivanecky. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var LikeImage: UIImageView!
    
    var post: Post!
    var request: Request?
    var likeRef: Firebase!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        LikeImage.addGestureRecognizer(tap)
        LikeImage.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
         profileImg.layer.cornerRadius = profileImg.frame.size.width/2
         profileImg.clipsToBounds = true
         showcaseImg.clipsToBounds = true
    }
    
    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            
            if img != nil {
                self.showcaseImg.image = img
            } else {
                
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response( completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                })
            }
            
        } else {
            self.showcaseImg.hidden = true
        }
        
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.LikeImage.image = UIImage(named: "icon-upvote")
            } else {
                self.LikeImage.image = UIImage(named: "icon-upvote-active")
            }
            
        })

    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.LikeImage.image = UIImage(named: "icon-upvote")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.LikeImage.image = UIImage(named: "icon-upvote-active")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
            
        })
    }

}
