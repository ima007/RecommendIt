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
            addLocationButton.hidden = true
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
            UIAlertView(title: "Oops", message: "You need to select a location", delegate: self, cancelButtonTitle: "Ok, let me try again").show()
            return
        }
        if notesTextView.text == "" {
            UIAlertView(title: "Oops", message: "You need to enter some notes", delegate: self, cancelButtonTitle: "Ok, let me try again").show()
            return
        }
        
        thisLocation = LocationModel(entity: description!, insertIntoManagedObjectContext: managedObjectContext)
        thisLocation.name = yelpBusiness.name
        thisLocation.city = ""
        thisLocation.notes = notesTextView.text
        
        var imageUrl:NSURL = NSURL(string: yelpBusiness.image!)!
        let request:NSURLRequest = NSURLRequest(URL: imageUrl)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                var image = UIImage(data: data)!
                self.thisLocation.image = UIImagePNGRepresentation(image)
                
                dispatch_async(dispatch_get_main_queue(), {
                    (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
