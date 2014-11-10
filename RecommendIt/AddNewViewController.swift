//
//  AddNewViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 10/19/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit
import CoreData

class AddNewViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: UIButton) {
        let description = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        var thisLocation:LocationModel = LocationModel(entity: description!, insertIntoManagedObjectContext: managedObjectContext)
        thisLocation.name = locationTextField.text
        thisLocation.city = cityTextField.text
        thisLocation.notes = notesTextField.text
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
