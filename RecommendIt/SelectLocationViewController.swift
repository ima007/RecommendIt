//
//  SelectLocationViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 10/19/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit

class SelectLocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var locationSearch: UISearchBar!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var currentCityView: UIView!
    
    // yelp stuff
    let yelpConsumerKey = "CIjHXVpOG4k6YQiuPVcP2g"
    let yelpConsumerSecret = "phjV1IV5KswhCQK_CWMN2s5Y-3U"
    let yelpToken = "iG8HC_jBdHEMiYC2JOjsaZ2v7fYmoujO"
    let yelpTokenSecret = "UsRzWpAPQYtAyZxwWuuSDd7pOOk"
    
    // other view controllers
    var addNewVC: AddNewViewController!
    
    var client: YelpClient!
    var results: [YelpBusinessModel] = []
    var currentCity = ""
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        // city selection
        currentCity = "San Jose"
        cityNameLabel.text = currentCity.capitalizedString
        locationSearch.becomeFirstResponder()
        
    }
    
    // Get the results from Yelp
    func getBusinessResults(searchTerm: String) -> Void {
        client.searchWithTerm(searchTerm, location: currentCity, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            self.results.removeAll(keepCapacity: false)
            let businesses = response["businesses"] as NSArray
            
            for business in businesses {
                var businessModel = YelpBusinessModel(name: business["name"] as String)
                businessModel.image = business["image_url"] as? String
                businessModel.url = business["mobile_url"] as? String
                // TODO: Figure out how to get city
                // businessModel.city = (business["location"] as String)
                self.results.append(businessModel)
            }
            self.resultsTableView.reloadData()
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
        }
    }
    
    // UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        getBusinessResults(searchText)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedBusiness = self.results[indexPath.row] as YelpBusinessModel
        addNewVC?.yelpBusiness = selectedBusiness
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let result = self.results[indexPath.row] as YelpBusinessModel
        var cell = UITableViewCell()
        var label = UILabel(frame: CGRectMake(25, 0, cell.frame.width - 50, cell.frame.height))
        label.text = result.name
        cell.addSubview(label)
        cell.sizeToFit()
        return cell
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            return
        }
        
        var alertTextField = alertView.textFieldAtIndex(0)
        cityNameLabel.text = alertTextField!.text.capitalizedString
        currentCity = alertTextField!.text
        locationSearch.becomeFirstResponder()
    }
    
    @IBAction func changeButtonPressed(sender: AnyObject) {
        var alert: UIAlertView = UIAlertView(title: "Choose Location", message: "Enter a city", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Change")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        locationSearch.resignFirstResponder()
        alert.show()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
