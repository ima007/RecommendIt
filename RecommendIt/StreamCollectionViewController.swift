//
//  StreamCollectionViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 12/9/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class StreamCollectionViewController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UIAlertViewDelegate {
    
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    var fetchedArchivedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var noItemsView: UIView!
    var selectedLocation: LocationModel!
    var showArchivedResults = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get saved locations
        updateFetchedResults(showArchivedResults)
        
        // custom nav bar
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.titleTextAttributes = titleDict
        
        // show a message if there are no recommendations
        self.noItemsView = setupNewItemsView()
        if fetchedResultsController.fetchedObjects?.count == 0 {
            self.collectionView?.addSubview(self.noItemsView)
        }
        
        // using a nib to have better control of the cell
        var locationCellNib = UINib(nibName: "LocationCell", bundle: nil)
        self.collectionView!.registerNib(locationCellNib, forCellWithReuseIdentifier: "LocationCell")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // does the user want to see archived recommendations?
        var userSettings = NSUserDefaults.standardUserDefaults()
        showArchivedResults = (userSettings.objectForKey("archived") as String == "YES") ? true : false
        updateFetchedResults(showArchivedResults)
        self.collectionView?.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        // reset the view
        self.collectionView!.frame.origin.y = 0
        self.navigationController?.view.frame.origin.y = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell:LocationCell = collectionView.dequeueReusableCellWithReuseIdentifier("LocationCell", forIndexPath: indexPath) as LocationCell
        let thisLocation = fetchedResultsController.objectAtIndexPath(indexPath) as LocationModel
        var buttonTitle: String
        
        if (thisLocation.archived) {
            buttonTitle = "Unarchive"
            cell.layer.opacity = 0.25
        } else {
            buttonTitle = "Archive"
            cell.layer.opacity = 1.0
        }
        
        cell.nameLabel.text = thisLocation.name
        cell.imageView.image = UIImage(data: thisLocation.image)
        cell.notesLabel.text = thisLocation.notes
        
        cell.yelpButton.addTarget(self, action: Selector("yelpButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        cell.archiveButton.addTarget(self, action: Selector("archiveButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        cell.archiveButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        cell.deleteButton.addTarget(self, action: Selector("deleteButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        // make things look a bit nicer
        cell.imageView.layer.cornerRadius = 2.0
        cell.imageView.clipsToBounds = true

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // target width of each cell - widht of the collectionView
        let targetWidth: CGFloat = collectionView.frame.width - 20.0
        
        // setup a prototype cell
        var cell: LocationCell = NSBundle.mainBundle().loadNibNamed("LocationCell", owner: self, options: nil)[0] as LocationCell
        let thisLocation = fetchedResultsController.objectAtIndexPath(indexPath) as LocationModel
        
        cell.nameLabel.text = thisLocation.name
        cell.notesLabel.text = thisLocation.notes
        
        // resize - layoutSubviews in LocationCell controller
        cell.layoutIfNeeded()
        
        // get the size based on constraints
        var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        
        // force width
        size.width = targetWidth
        
        return size
        
    }

    // UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedLocation = fetchedResultsController.objectAtIndexPath(indexPath) as LocationModel
        self.performSegueWithIdentifier("EditSegue", sender: self)
    }
    
    // UIViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditSegue" {
            let editVC:EditViewController = segue.destinationViewController as EditViewController
            editVC.streamVC = self
        }
        if segue.identifier == "AddNewSegue" {
            // animate this view to fall back
            UIView.animateWithDuration(1, animations: {
                self.collectionView!.frame.origin.y = 500.0
                self.navigationController?.view.frame.origin.y = 500.0
            })
        }
    }
    
    // NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.collectionView?.reloadData()
        if fetchedResultsController.fetchedObjects?.count == 0 {
            self.collectionView?.addSubview(noItemsView)
        } else {
            noItemsView.removeFromSuperview()
        }
    }
    
    // buttons
    func yelpButtonPressed(sender: UIButton) {
        getLocationFromButton(sender).goToYelp()
    }
    func archiveButtonPressed(sender: UIButton) {
        selectedLocation = getLocationFromButton(sender)
        var msg: String
        if (selectedLocation.archived) {
            msg = "Are you sure you want to unarchive this location?"
        } else {
            msg = "Are you sure you want to archive this location?"
        }
        var alert = UIAlertView(title: "Archive", message: msg, delegate: self, cancelButtonTitle: "Nevermind", otherButtonTitles: "Yes!")
        alert.tag = 2
        alert.show()
    }
    func deleteButtonPressed(sender: UIButton) {
        selectedLocation = getLocationFromButton(sender)
        var alert = UIAlertView(title: "Delete", message: "Are you sure you want to delete this location? You'll lose it forever and ever!", delegate: self, cancelButtonTitle: "Aw shucks, nevermind.", otherButtonTitles: "Get it outta here!")
        alert.tag = 3
        alert.show()
    }
    
    // alerts
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        // archive alert
        if alertView.tag == 2 {
            if buttonIndex == 1 {
                selectedLocation.archived = !selectedLocation.archived
                (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
            }
        }
            
        // delete alert
        if alertView.tag == 3 {
            if buttonIndex == 1 {
                managedObjectContext.deleteObject(selectedLocation)
                (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
            }
        }
        
    }
    
    // helper functions
    func updateFetchedResults(showArchived: Bool) -> Void {
        var request = NSFetchRequest(entityName: "Location")
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        let sortByArchived = NSSortDescriptor(key: "archived", ascending: true)
        let predicate = (!showArchived) ? NSPredicate(format: "archived == NO") : nil
        request.sortDescriptors = [sortByArchived, sortByName]
        request.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
    }
    
    func setupNewItemsView() -> UIView {
        var theView: UIView = UIView(frame: self.collectionView!.frame)
        
        var theLabel: UILabel = UILabel(frame: CGRectMake((self.collectionView!.frame.width / 2) - 125, 50, 250, 100))
        theLabel.font = UIFont(name: "Helvetica Neue", size: 13.0)
        theLabel.numberOfLines = 0
        theLabel.textColor = UIColor.darkGrayColor()
        theLabel.textAlignment = NSTextAlignment.Center
        
        theLabel.text = "It appears that you haven't yet added any recommendations! Get out there and chat it up with some friends about food. Once you have a recommendation, press the + button in the upper right corner to add it!"
        
        theView.addSubview(theLabel)

        return theView
    }
    
    func getLocationFromButton(button: UIButton) -> LocationModel {
        var buttonOriginInTableView = button.convertPoint(CGPointZero, toView: self.collectionView)
        var indexPath = self.collectionView?.indexPathForItemAtPoint(buttonOriginInTableView)
        return fetchedResultsController.objectAtIndexPath(indexPath!) as LocationModel
    }
    
    func deleteLocation(location: LocationModel) {
        managedObjectContext.deleteObject(location)
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
    }

}
