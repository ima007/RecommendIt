//
//  LocationModel.swift
//  RecommendIt
//
//  Created by Derrick Showers on 10/18/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import Foundation
import CoreData

@objc(LocationModel)
class LocationModel: NSManagedObject {
    
    @NSManaged var city:String
    @NSManaged var name:String
    @NSManaged var notes:String
    @NSManaged var recommendedBy:String
    
}