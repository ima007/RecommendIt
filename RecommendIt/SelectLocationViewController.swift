//
//  SelectLocationViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 10/19/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit
import CoreLocation

class SelectLocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate, CLLocationManagerDelegate {
    
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
    
    let locationManager = CLLocationManager()
    
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
        
        // we need to do all this just to get the text color in the serach bar to be white :(
        for sv in locationSearch.subviews[0].subviews {
            if sv.isKindOfClass(UITextField) {
                var textField: UITextField = sv as UITextField;
                textField.textColor = UIColor.whiteColor()
            }
        }
        
        // setup the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    // Get the results from Yelp
    func getBusinessResults(searchTerm: String) -> Void {
        client.searchWithTerm(searchTerm, location: currentCity, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            self.results.removeAll(keepCapacity: false)
            let businesses = response["businesses"] as NSArray
            
            for business in businesses {
                var businessModel = YelpBusinessModel(yelpId: business["id"] as String)
                if let businessName = business["name"] as? String {
                    businessModel.name = businessName
                }
                if let businessImage = business["image_url"] as? String {
                    businessModel.image = businessImage
                }
                if let businessUrl = business["mobile_url"] as? String {
                    businessModel.url = businessUrl
                }
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
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
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
        locationSearch.becomeFirstResponder()
        
        if buttonIndex == 0 {
            return
        }
        
        // stop getting currentn location
        self.locationManager.stopUpdatingLocation()
        
        // clear current search
        self.results = []
        resultsTableView.reloadData()
        
        var alertTextField = alertView.textFieldAtIndex(0)
        cityNameLabel.text = alertTextField!.text.capitalizedString
        currentCity = alertTextField!.text
    }
    
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            if placemarks.count > 0 {
                var locality = (placemarks[0] as CLPlacemark).locality
                self.currentCity = locality
                self.cityNameLabel.text = locality
            }
        })
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
