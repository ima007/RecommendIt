//
//  SelectLocationViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 10/19/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

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
    
    var isSearching = false
    var isStarted = false
    
    var client: YelpClient!
    var results: [YelpBusinessModel] = []
    var currentCity = ""
    var currentSearchText = ""
    
    var debouncedBusinessResults:(()->())?
    
    let locationManager = CLLocationManager()
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debouncedBusinessResults = debounce(NSTimeInterval(0.25),dispatch_get_main_queue(),getBusinessResults)
        
        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        // city selection
        currentCity = "San Francisco"
        cityNameLabel.text = currentCity.capitalizedString
        locationSearch.becomeFirstResponder()
        
        // we need to do all this just to get the text color in the search bar to be white :(
        
        for sv in locationSearch.subviews[0].subviews {
            if sv.isKindOfClass(UITextField) {
                var textField: UITextField = sv as UITextField;
                textField.textColor = UIColor.whiteColor()
            }
        }

        
        // setup the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.rowHeight = UITableViewAutomaticDimension
        // Need to set estimated height to *something* to allow height Automatic Dimension
        // to take place.
        resultsTableView.estimatedRowHeight = 100
        resultsTableView.tableFooterView = UIView(frame:CGRectZero)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    // Get the results from Yelp
    func getBusinessResults() -> Void {
        //This prevents a call from being made if there's no content
        //is actually "count" instead of "countElements" in newer versions of swift
        if countElements(currentSearchText) == 0{
            self.results = []
            self.resultsTableView.reloadData()
            return
        }
        isStarted = true
        //TODO: Could use a cocoapod-provided loader here instead
        if !isSearching {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.resultsTableView.alpha = 0.5
            })
        }
        isSearching = true
        client.searchWithTerm(currentSearchText, location: currentCity, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            self.results.removeAll(keepCapacity: false)
            let businesses = response["businesses"] as NSArray
            
            for business in businesses {
                if let business = business as? [String:AnyObject]{
                    var businessModel = YelpBusinessModel(business: business)
                    self.results.append(businessModel)
                }
            }
            self.isSearching = false
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.resultsTableView.alpha = 1.0
            })
            self.resultsTableView.reloadData()
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
        }
    }
    
    // UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.currentSearchText = searchText
        if let debouncedBusinessResults = debouncedBusinessResults{
            debouncedBusinessResults()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //If there are no actual result cells, don't try to access them.
        //This happens if the user taps on the "Start typing/No results" cell.
        if results.count > 0 {
            let selectedBusiness = self.results[indexPath.row] as YelpBusinessModel
            let description = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
            
            // if this is a new location, create a new instance of the LocationModel
            if (addNewVC?.thisLocation == nil) {
                addNewVC?.thisLocation = LocationModel(entity: description!, insertIntoManagedObjectContext: managedObjectContext)
            }
            addNewVC?.thisLocation.archived = false
            
            // and always do this (new LocationModel or not)
            addNewVC?.thisLocation.name = selectedBusiness.name!
            addNewVC?.thisLocation.yelpId = selectedBusiness.yelpId
            
            selectedBusiness.getImage { (imageData) -> () in
                self.addNewVC.thisLocation.image = imageData as NSData
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            locationSearch.becomeFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.results.count > 0{
            return self.results.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.results.count > 0{
            let result = self.results[indexPath.row]
            var cell = tableView.dequeueReusableCellWithIdentifier("YelpResultCell") as YelpResultCell
            cell.setContent(result)
            cell.backgroundColor = UIColor.clearColor()
            cell.sizeToFit()
            return cell
        }else{
            let cell = UITableViewCell()
            cell.textLabel?.text = isStarted ? "No results. Try another search." : "Start typing to search!"
            cell.selectionStyle = .None
            cell.sizeToFit()
            return cell
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        locationSearch.becomeFirstResponder()
        
        if buttonIndex == 0 {
            return
        }
        
        // stop getting current location
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
            if (error == nil) {
                if placemarks.count > 0 {
                    var locality = (placemarks[0] as CLPlacemark).locality
                    self.currentCity = locality
                    self.cityNameLabel.text = locality
                    self.locationManager.stopUpdatingLocation()
                }
            }
            else {
                println(error)
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
