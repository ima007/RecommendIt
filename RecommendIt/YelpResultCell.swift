//
//  YelpResultCell.swift
//  RecommendIt

import UIKit

class YelpResultCell: UITableViewCell {

    @IBOutlet weak private var bizImage: UIImageView!
    
    @IBOutlet weak private var bizName: UILabel!
    
    @IBOutlet weak private var bizRatingImage: UIImageView!
    
    @IBOutlet weak private var bizReviews: UILabel!
    
    @IBOutlet weak private var bizAddress: UILabel!
    
    @IBOutlet weak private var bizCategories: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bizImage.layer.cornerRadius = 3
        bizImage.clipsToBounds = true
        
        autoLayoutBug()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func autoLayoutBug(){
        bizName.preferredMaxLayoutWidth = bizName.frame.size.width
    }
    
    func setContent(business:YelpBusinessModel){
        bizImage.backgroundColor = UIColor.clearColor()
        bizImage.setImageWithURL(business.imageNsUrl, placeholderImage: UIImage(named: "Placeholder"))
        bizRatingImage.backgroundColor = UIColor.clearColor()
        bizRatingImage.setImageWithURL(business.ratingImageNsUrl)
        bizName.text = business.name
        bizReviews.text = business.reviewsStatement
        bizAddress.text = business.singleDisplayAddress
        bizCategories.text = business.categoriesCommaDelimited
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        autoLayoutBug()
    }
    

}
