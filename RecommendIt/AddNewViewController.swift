//
//  AddNewViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 12/7/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit
import CoreData

class AddNewViewController: UIViewController {
    
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    var yelpBusiness: YelpBusinessModel!
    var thisLocation: LocationModel!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
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
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        let description = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
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
