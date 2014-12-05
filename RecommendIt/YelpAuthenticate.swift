//
//  YelpAuthenticate.swift
//  RecommendIt
//
//  Created by Derrick Showers on 12/3/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

//class YelpAuthenticate: BDBOAuth1RequestOperationManager {
//    
//    var accessToken: String!
//    var accessSecret: String!
//    var consumerKey: String!
//    var consumerSecret: String!
//    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    init(consumerKey ck: String!, consumerSecret cs: String!, accessToken at: String!, accessSecret ase: String!) {
//        self.accessToken = at
//        self.accessSecret = ase
//        var baseUrl = NSURL(string: "http://api.yelp.com/v2/")
//        super.init(baseURL: baseUrl, consumerKey: ck, consumerSecret: cs);
//        
//        var token = BDBOAuth1Credential(token: at, secret: ase, expiration: nil)
//        
//        self.requestSerializer.saveAccessToken(token)
//    }
//    
//    func searchWithTerm(term: String, parameters: Dictionary<String, String>? = nil, offset: Int = 0, limit: Int = 20, success: (AFHTTPRequestOperation!, AnyObject!) -> Void, failure: (AFHTTPRequestOperation!, NSError!) -> Void) -> AFHTTPRequestOperation! {
//        var params: NSMutableDictionary = [
//            "term": term,
//            "offset": offset,
//            "limit": limit
//        ]
//        for (key, value) in parameters! {
//            params.setValue(value, forKey: key)
//        }
//        return self.GET("search", parameters: params, success: success, failure: failure)
//    }
//}
