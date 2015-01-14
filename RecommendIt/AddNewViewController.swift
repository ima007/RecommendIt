//
//  AddNewViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 12/7/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit
import CoreData

class AddNewViewController: UIViewController, UITextViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var notesPlaceholderLabel: UILabel!
    
    var yelpBusiness: YelpBusinessModel!
    var thisLocation: LocationModel!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.notesTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        notesTextView.becomeFirstResponder()
        if (yelpBusiness != nil) {
            locationNameLabel.text = yelpBusiness.name
            locationNameLabel.hidden = false
        }
    }
    
    // UIViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSelectLocation" {
            let selectLocationVC:SelectLocationViewController = segue.destinationViewController as SelectLocationViewController
            selectLocationVC.addNewVC = self
        }
    }
    
    // UITextView
    func textViewDidChange(textView: UITextView) {
        if textView.text == "" {
            notesPlaceholderLabel.hidden = false
        } else {
            notesPlaceholderLabel.hidden = true
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        let description = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        
        // check to make sure all required fields have been entered
        if yelpBusiness == nil {
            showError("You need to select a location")
            return
        }
        if notesTextView.text == "" {
            showError("You need to enter some notes")
            return
        }
        
        thisLocation = LocationModel(entity: description!, insertIntoManagedObjectContext: managedObjectContext)
        thisLocation.name = yelpBusiness.name
        thisLocation.yelpId = yelpBusiness.yelpId
        thisLocation.city = ""
        thisLocation.notes = notesTextView.text
        thisLocation.archived = false
        
        yelpBusiness.getImage({ (imageData) -> () in
            self.thisLocation.image = imageData
        })
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // helper functions
    func showError(msg: String) {
        UIAlertView(title: "Oops", message: msg, delegate: self, cancelButtonTitle: "Ok, let me try again").show()
    }
}
