//
//  AddNewViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 10/19/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit
import CoreData

class AddNewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    
    // yelp stuff
    let yelpConsumerKey = "CIjHXVpOG4k6YQiuPVcP2g"
    let yelpConsumerSecret = "phjV1IV5KswhCQK_CWMN2s5Y-3U"
    let yelpToken = "iG8HC_jBdHEMiYC2JOjsaZ2v7fYmoujO"
    let yelpTokenSecret = "UsRzWpAPQYtAyZxwWuuSDd7pOOk"
    
    var client: YelpClient!
    var results: [YelpBusinessModel] = []
    var cities: [String] = []
    var currentCity = ""
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        // city selection
        cities = ["San Jose","San Francisco","New York","Lancaster"]
        currentCity = cities[0]
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
    
    // UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = NSAttributedString(string: cities[row])
        return title
    }
    
    // UIPickerViewDelgate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentCity = cities[row]
    }
    
    // UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        getBusinessResults(searchText)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// We'll need this later when we add the buttons back
//    @IBAction func cancelButtonTapped(sender: UIButton) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    @IBAction func saveButtonTapped(sender: UIButton) {
//        let description = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
//        var thisLocation:LocationModel = LocationModel(entity: description!, insertIntoManagedObjectContext: managedObjectContext)
//        thisLocation.name = locationTextField.text
//        thisLocation.city = cityTextField.text
//        thisLocation.notes = notesTextField.text
//        
//        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
//        
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
    
}
