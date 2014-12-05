//
//  StreamController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 10/18/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit
import CoreData

class StreamController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get saved locations
        fetchedResultsController = setupController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:LocationCell = collectionView.dequeueReusableCellWithReuseIdentifier("LocationCell", forIndexPath: indexPath) as LocationCell
        let thisLocation = fetchedResultsController.objectAtIndexPath(indexPath) as LocationModel
        cell.nameLabel.text = thisLocation.name
        
        // configure height, width, boundaries and stuff
        cell.frame = CGRectMake(0, cell.frame.origin.y, self.collectionView.frame.width, cell.frame.height)
        
        return cell
    }
    
    
    
    // UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("EditSegue", sender: self)
    }
    
    
    
    
    // NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.reloadData()
    }
    
    
    
    // helper functions
    func setupController() -> NSFetchedResultsController {
        var request = NSFetchRequest(entityName: "Location")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }

}
