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
    
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
        println("preferredLayoutAttributesFittingAttributes \(layoutAttributes.frame)")
        return layoutAttributes
    }
}
