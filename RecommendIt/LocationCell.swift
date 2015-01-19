//
//  LocationCell.swift
//  RecommendIt
//
//  Created by Derrick Showers on 10/18/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit

@objc(LocationCell)
class LocationCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var yelpButton: UIButton!
    @IBOutlet weak var archiveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // set the max width, or else it will just be one long line of text
        notesLabel.preferredMaxLayoutWidth = self.bounds.width - 111
    }

}
