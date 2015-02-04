//
//  EditViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 10/19/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationNotes: UILabel!
    
    var streamVC: StreamCollectionViewController!
    var loc: LocationModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the location stored
        loc = streamVC.selectedLocation;
        
        // configure stuff based on selected location
        self.title = loc.name
        locationImage.image = UIImage(data: loc.image)
        locationName.text = loc.name
        locationNotes.text = loc.notes
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        // archive alert
        if alertView.tag == 1 {
            loc.archived = true
            self.navigationController?.popViewControllerAnimated(true)
            if buttonIndex == 1 {
                loc.goToYelp()
            }
        }
            
        // delete alert
        else {
            if buttonIndex == 0 {
                return
            } else {
                streamVC.deleteLocation(loc)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditNotesSegue" {
            let addNewVC: AddNewViewController = segue.destinationViewController as AddNewViewController
            addNewVC.editVC = self
        }
    }
    
    @IBAction func archiveButtonPressed(sender: AnyObject) {
        var alert: UIAlertView = UIAlertView(title: "Archived!", message: "Would you like to go to the location's Yelp page so that you can review and/or check-in?", delegate: self, cancelButtonTitle: "Nah. Yelp is for losers.", otherButtonTitles: "Of course! Why wouldn't I?")
        alert.tag = 1
        alert.show()
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        var alert: UIAlertView = UIAlertView(title: "Are you sure?", message: "If you delete this recommendation, it will be gone forever!", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Delete")
        alert.tag = 2
        alert.show()
    }

    @IBAction func editButtonClicked(sender: AnyObject) {
        
    }
    
    @IBAction func yelpButtonPressed(sender: AnyObject) {
        loc.goToYelp()
    }
    
}
