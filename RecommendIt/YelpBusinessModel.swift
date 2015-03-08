//
//  YelpBusiness.swift
//  RecommendIt
//
//  Created by Derrick Showers on 12/4/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import Foundation

class YelpBusinessModel {
    
    // required
    var yelpId: String
    
    // optional properties
    var name: String?
    var image: String?
    var url: String?
    var city: String?
    
    var reviews:Int?
    var reviewsStatement:String?{
        var statement:String?
        if let reviews = reviews{
            statement = reviews != 1 ? "\(String(reviews)) reviews" : "\(String(reviews)) review"
        }else{
            statement = "No reviews"
        }
        return statement
    }
    
    private var categories:[[String]]?
    private var ratingImageUrl:String?
    private var imageUrl:String?
    
    var ratingImageNsUrl:NSURL? {
        if let url = ratingImageUrl{
            return NSURL(string: url)
        }
        return nil
    }
    
    var imageNsUrl:NSURL? {
        if let url = imageUrl {
            return NSURL(string: url)
        }
        return nil
    }
    
    private var displayAddress: [String]?
    var singleDisplayAddress:String? {
        if let address = displayAddress{
            return ", ".join(address)
        }
        return nil
    }
    
    // The YelpAPI provides categories as a weird multidimensional array
    // of "pretty" names and code names.
    // This simply provides a comma-delimted list of the "pretty" names
    lazy var categoriesCommaDelimited:String? = {
        [unowned self] in
        var categoryStatement:String?
        
        if let categories = self.categories{
            var collection = [String]()
            for item in categories{
                if item.count > 0{
                    collection.append(item[0])
                }
            }
            categoryStatement = ", ".join(collection)
        }
        return categoryStatement
        }()
    
    init(yelpId: String) {
        self.yelpId = yelpId
    }
    
    init(business:[String:AnyObject]){
        self.yelpId = business["id"] as String
        if let businessName = business["name"] as? String {
            name = businessName
        }
        if let businessImage = business["image_url"] as? String {
            image = businessImage
            imageUrl = businessImage
        }
        if let businessUrl = business["mobile_url"] as? String {
            url = businessUrl
        }
        if let categories = business["categories"] as? [[String]]{
            self.categories = categories
        }
        if let ratingImageUrl = business["rating_img_url"] as? String{
            self.ratingImageUrl = ratingImageUrl
        }
        if let reviews = business["review_count"] as? Int{
            self.reviews = reviews
        }
        if let location = business["location"] as? [String:AnyObject]{
            if let displayAddress = location["display_address"] as? [String]{
                self.displayAddress = displayAddress
            }
        }
    }
    
    func getImage(completionHandler: (imageData: NSData) -> ()) {
        
        if self.image == nil {
            var image = UIImage(named: "Placeholder")
            var imageData = UIImagePNGRepresentation(image)
            completionHandler(imageData: imageData)
            return
        }
        
        var imageUrl: NSURL = NSURL(string: self.image!)!
        let request: NSURLRequest = NSURLRequest(URL: imageUrl)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                var image = UIImage(data: data)!
                var imageData = UIImagePNGRepresentation(image)
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(imageData: imageData)
                })
                
            }
            else {
                // log the error
                println("Error: \(error.localizedDescription)")
                
                // use a placeholder instead
                var image = UIImage(named: "Placeholder")
                var imageData = UIImagePNGRepresentation(image)
                completionHandler(imageData: imageData)
            }
        })
    }
    
}