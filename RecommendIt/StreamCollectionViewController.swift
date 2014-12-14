//
//  StreamCollectionViewController.swift
//  RecommendIt
//
//  Created by Derrick Showers on 12/9/14.
//  Copyright (c) 2014 Derrick Showers. All rights reserved.
//

import UIKit
import CoreData

class StreamCollectionViewController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!

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
        
        // using a nib to have better control of the cell
        var locationCellNib = UINib(nibName: "LocationCell", bundle: nil)
        self.collectionView!.registerNib(locationCellNib, forCellWithReuseIdentifier: "LocationCell")
        
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
