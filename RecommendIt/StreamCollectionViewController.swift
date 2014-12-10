//
//  StreamCollectionViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 12/9/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit
import CoreData

let reuseIdentifier = "Cell"

class StreamCollectionViewController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // get saved locations
        fetchedResultsController = setupController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
        // custom nav bar
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = titleDict
        
//        var layout: UICollectionViewFlowLayout = self.collectionView?.collectionViewLayout as UICollectionViewFlowLayout
//        layout.estimatedItemSize = CGSizeMake(370.0, 25.0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return fetchedResultsController.sections![section].numberOfObjects
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:LocationCell = collectionView.dequeueReusableCellWithReuseIdentifier("LocationCell", forIndexPath: indexPath) as LocationCell
        let thisLocation = fetchedResultsController.objectAtIndexPath(indexPath) as LocationModel
        
        cell.nameLabel.text = thisLocation.name
        cell.imageView.image = UIImage(data: thisLocation.image)
        cell.notesLabel.text = thisLocation.notes
        
        // make things look a bit nicer
        cell.imageView.layer.cornerRadius = 5.0
        cell.imageView.clipsToBounds = true
        cell.notesLabel.sizeToFit()
        
        // border
        var bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(10, cell.frame.height - 0.5, cell.frame.width - 20, 0.5)
        bottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        cell.layer.addSublayer(bottomBorder)
        
        println("collectionView \(cell.frame)")
        
        return cell
    }

    // UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("EditSegue", sender: self)
    }
    
    // NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.collectionView?.reloadData()
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
