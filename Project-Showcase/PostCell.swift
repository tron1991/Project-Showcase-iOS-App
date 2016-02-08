//
//  PostCell.swift
//  Project-Showcase
//
//  Created by Nick on 2016-02-07.
//  Copyright © 2016 Nicholas Ivanecky. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func drawRect(rect: CGRect) {
         profileImg.layer.cornerRadius = profileImg.frame.size.width/2
         profileImg.clipsToBounds = true
    }

}
