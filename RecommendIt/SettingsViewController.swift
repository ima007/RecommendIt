//
//  SettingsViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 2/4/15.
//  Copyright (c) 2015 Derrick Showers. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var userSettings: NSUserDefaults!

    @IBOutlet weak var archiveSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userSettings = NSUserDefaults.standardUserDefaults()
        
        if (userSettings.objectForKey("archived") != nil) {
            if (userSettings.objectForKey("archived") as String == "YES") {
                archiveSwitch.on = true
            } else {
                archiveSwitch.on = false
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func archiveSwitchChanged(sender: UISwitch) {
        if (sender.on) {
            userSettings.setObject("YES", forKey: "archived")
        } else {
            userSettings.setObject("NO", forKey: "archived")
        }
    }
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        userSettings.synchronize()
    }
}
