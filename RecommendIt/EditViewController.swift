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
        if buttonIndex == 0 {
            return
        } else {
            streamVC.deleteLocation(loc)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        var alert: UIAlertView = UIAlertView(title: "Are you sure?", message: "If you delete this recommendation, it will be gone forever!", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Delete")
        alert.show()
    }


}
