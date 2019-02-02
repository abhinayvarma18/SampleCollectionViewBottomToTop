//
//  BottomRightToLeftCollectionViewCell.swift
//  3x3Connect
//
//  Created by abhinay varma on 29/01/19.
//  Copyright © 2019 abhinay varma. All rights reserved.
//

import UIKit
import SDWebImage

class BottomRightToLeftCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var storyMainImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
    
    var dataModel:StoryDetailModel? {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        senderImageView.layer.masksToBounds = false
        senderImageView.layer.cornerRadius = senderImageView.bounds.size.height/2.0
        senderImageView.clipsToBounds = true
        // Initialization code
    }
    
    private func configure(){
        likeLabel.text = "xyz and \(dataModel?.likesAndComments?.totalLikes() ?? 0) others"
        titleLabel.text = dataModel?.title
        nameLabel.text = dataModel?.senderUser?.name
        timeLabel.text = dataModel?.fetchTimeLeft()
        guard let url = URL(string: (dataModel?.senderUser?.image) ?? "") else {return}
        senderImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "profilePhotoPlaceholder"), options: .avoidAutoSetImage) { (image, error, type, url) in
            if error == nil && image != nil {
                print("image name -: \(image.debugDescription)")
            }
        }
        storyMainImage.sd_setImage(with: URL(string: (dataModel?.imageUrl)!), placeholderImage: UIImage(named: "storyPhotoPlaceholder"), options: .avoidAutoSetImage) { (image, error, type, url) in
            if error == nil && image != nil {
                print("image name -: \(image.debugDescription)")
            }
        }
    }

}
