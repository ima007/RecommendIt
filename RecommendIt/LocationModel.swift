//
//  LocationModel.swift
//  RecommendIt
//
//  Created by Derrick Showers on 10/18/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import Foundation
import CoreData

let isYelpInstalled = UIApplication.sharedApplication().canOpenURL(NSURL(string: "yelp://")!)

@objc(LocationModel)
class LocationModel: NSManagedObject {
    
    @NSManaged var yelpId: String?
    @NSManaged var city: String?
    @NSManaged var name: String?
    @NSManaged var notes: String?
    @NSManaged var recommendedBy: String?
    @NSManaged var image: NSData?
    @NSManaged var archived: Bool
    
    func goToYelp() {
        if isYelpInstalled {
            UIApplication.sharedApplication().openURL(NSURL(string: "yelp:///biz/\(self.yelpId)")!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://yelp.com/biz/\(self.yelpId)")!)
        }
    }
    
}