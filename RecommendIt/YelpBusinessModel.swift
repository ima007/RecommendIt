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
    
    init(yelpId: String) {
        self.yelpId = yelpId
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