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

class StreamCollectionViewController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var noItemsView: UIView!
    var selectedLocation: LocationModel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // get saved locations
        fetchedResultsController = setupController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
        // custom nav bar
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
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
        
        cell.nameLabel.text = thisLocation.name
        cell.imageView.image = UIImage(data: thisLocation.image)
        cell.notesLabel.text = thisLocation.notes
        
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
    
    // helper functions
    func setupController() -> NSFetchedResultsController {
        var request = NSFetchRequest(entityName: "Location")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
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
    
    func deleteLocation(location: LocationModel) {
        managedObjectContext.deleteObject(location)
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
    }

}
