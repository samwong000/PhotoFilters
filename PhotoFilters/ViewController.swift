//
//  ViewController.swift
//  PhotoFilters
//
//  Created by Sam Wong on 13/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import UIKit
import CoreData
import OpenGLES
import CoreImage
import Social
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, GalleryDelegate {

    @IBOutlet weak var pickPhotoButton: UIButton!
    
    // add main imageView and its constraint outlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewTrailingContraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    
    // add new collectionView and its imageView contrainst Outlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
    //core data context 
    private var gpuContext : CIContext?
    private var originalThumbnail : UIImage?
    private var originalImage : UIImage?
    private var filters : [Filter]?
    private var filterThumbnails = [FilterThumbnail]()
    private let imageQueue = NSOperationQueue()
    private var context : NSManagedObjectContext?
    private var managedObjectContext : NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = UIImage(named: "photo4.jpg")
        self.originalImage = self.imageView.image
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        
        self.generateThumbnail()
        
        //Set GPU context!
        //set the key for image operations to NULL
        var options = [kCIContextWorkingColorSpace : NSNull()]
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.gpuContext = CIContext(EAGLContext: myEAGLContext, options: options)
        
        //Fetch filters
        let fetchRequest = NSFetchRequest(entityName: "Filter")
        var error : NSError?
        //executeFetchRquest will return array of object
        var sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        
        //fetch filters
        self.fetchFilters()
        
        //reset filter thumbnails
        self.resetFilterThumbnails()
        
        //must set database and delegate
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    //delete all NSManagedObject
    //Not used
    func deleteCoreData() {
        var fetchRequest = NSFetchRequest(entityName: "Filter")
        var error : NSError?
        
        //Returns an array of filters that meet the criteria specified by a given fetch request
        let fetchResults = context?.executeFetchRequest(fetchRequest, error: &error)
        println(fetchResults?.count)
        
        var index: Int
        for index = 0; index < fetchResults?.count; ++index {
            let managedObject : NSManagedObject = fetchResults?[index] as NSManagedObject
            context?.deleteObject(managedObject)
        }
        
        context?.save(nil)
    }
    
    func generateThumbnail() {
        let size = CGSize(width: 100, height: 100)
        //Creates a graphics context and makes it the current context.
        UIGraphicsBeginImageContext(size)
        self.imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        //Removes the current graphics context from the top of the stack.
        UIGraphicsEndImageContext()
    }
    
    func fetchFilters() {
        var fetchRequest = NSFetchRequest(entityName: "Filter")
        var error : NSError?
        
        if let filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Filter] {
            if filters.isEmpty {
                //if empty, seed it
                var seeder = CoreDataSeeder(context: self.managedObjectContext!)
                seeder.seedCoreData()
                
                //fetch it from database
                self.filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Filter]
            } else {
                self.filters = filters
            }
        }
    }
    
    func resetFilterThumbnails() {
        var newFilters = [FilterThumbnail]()
        for var index = 0; index < self.filters?.count; ++index {
            var filter = self.filters?[index]
            var filterName = filter?.name
            var thumbnail = FilterThumbnail(name: filterName!, thumbnail: self.originalThumbnail!, queue: self.imageQueue, context: self.gpuContext!)
            newFilters.append(thumbnail)
        }
        self.filterThumbnails = newFilters
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {

        let alertController = UIAlertController(title: nil, message: "Choose an option", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let postToTweetAction = UIAlertAction(title: "Post to Twitter", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.postImageToTweet()
        }
        
        let addToPhotoFrameworkAction = UIAlertAction(title: "Add to Photo Framework", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.addToPhotoFramework()
        }
        
        let avFoundationCameraAction = UIAlertAction(title: "AV Foundation Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.showAVFoundationCameraVC()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.showGalleryVC()
        }

        let photoAction = UIAlertAction(title: "Photo Framework", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.showPhotoFrameworkVC()
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            
            //            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            //
            //            }
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.delegate = self
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        let filterAction = UIAlertAction(title: "Filters", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.enterFilterMode()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action ) -> Void in
        }

        alertController.addAction(postToTweetAction)
        alertController.addAction(addToPhotoFrameworkAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(photoAction)
        alertController.addAction(avFoundationCameraAction)
        alertController.addAction(filterAction)
        alertController.addAction(cancelAction)
        
        //show alertController
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        self.imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.generateThumbnail()
        self.resetFilterThumbnails()
        self.collectionView.reloadData()
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FilterThumbnailCell
        var filterThumbnail = self.filterThumbnails[indexPath.row]
        if filterThumbnail.filteredThumbnail != nil {
            //set the filter thumb nail to the cell
            cell.imageView.image = filterThumbnail.filteredThumbnail
        } else {
            cell.imageView.image = filterThumbnail.originalThumbnail
            filterThumbnail.generateThumbnail({ (image) -> (Void) in
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterThumbnailCell {
                    cell.imageView.image = image
                }
            })
        }
        
        //cell.imageView.backgroundColor = UIColor.blueColor()
        return cell
    }
    
    //Asks the data source for the number of items in the specified section. (required)
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filterThumbnails.count
    }
    
    //When user clicks on the filter
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let filterThumbnailManager = self.filterThumbnails[indexPath.row]
        
        filterThumbnailManager.applyFilterToImage(self.originalImage!, completionHandler: { (filteredImage) -> Void in
            self.imageView.image = filteredImage
        })
        
    }
    
    func addToPhotoFramework() {
        // method 1
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            println("")
            PHAssetChangeRequest.creationRequestForAssetFromImage(self.imageView.image)
            }, completionHandler: nil)
        
//        //method 2
//        var myAlbum = PHCollectionList.fetchCollectionListsWithType(PHCollectionListType.Folder, subtype: PHCollectionListSubtype.RegularFolder, options: nil)
//        
//        
//        //method 3
//        UIImageWriteToSavedPhotosAlbum(self.imageView, nil, nil, nil )
    }
    
    func postImageToTweet() {
        
        if  SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            var tweetSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetSheet.setInitialText("Post to Twitter!")
            tweetSheet.addImage(self.imageView.image)
            
            self.presentViewController(tweetSheet, animated: true, completion: nil)
        }
    }
    
    func showAVFoundationCameraVC() {
        // open main storyboard, click on the respective view controller -> inspector view -> set storyBoardID
        let destinationVC = self.storyboard?.instantiateViewControllerWithIdentifier("AVFoundationCameraVC") as AVFoundationCameraViewController
        destinationVC.delegate = self
        self.navigationController?.presentViewController(destinationVC, animated: true, completion: nil)
    }
    
    func showPhotoFrameworkVC() {
        // open main storyboard, click on the respective view controller -> inspector view -> set storyBoardID
        let destinationVC = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoFrameworkVC") as PhotoFrameworkViewController
        destinationVC.delegate = self
        self.navigationController?.presentViewController(destinationVC, animated: true, completion: nil)
    }
    
    func showGalleryVC() {
        // open main storyboard, click on the respective view controller -> inspector view -> set storyBoardID
        let destinationVC = self.storyboard?.instantiateViewControllerWithIdentifier("GalleryVC") as GalleryViewController
        destinationVC.delegate = self
        self.navigationController?.presentViewController(destinationVC, animated: true, completion: nil)
    }
    
    func enterFilterMode() {
        self.pickPhotoButton.enabled = false
        
        let factor = 3 as CGFloat
        
        //shrink the size of main imageView
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant * factor
        self.imageViewTrailingContraint.constant = self.imageViewTrailingContraint.constant * factor
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant * factor
        //show the filter collectionView
        self.collectionViewBottomConstraint.constant = 100
        
        //show the filter collectionView with animation effect
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        //create doneButton that leads to exitFilteringMode function
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilterMode")
        //add button onto navigation bar
        self.navigationItem.rightBarButtonItem = doneButton
        
    }
    
    func exitFilterMode() {
        self.pickPhotoButton.enabled = true
        
        let factor = 3 as CGFloat
        
        //return the contraint to normal
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant / factor
        self.imageViewTrailingContraint.constant = self.imageViewTrailingContraint.constant / factor
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant / factor
        //hide the filter collection view
        self.collectionViewBottomConstraint.constant = -200
        //show the filter collectionView with animation effect
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        //remove the button
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func didTapOnPicture(image: UIImage) {
        println("didTapOnPicture")
        self.imageView.image = image
        self.originalImage = image
        
        self.generateThumbnail()
        self.resetFilterThumbnails()
        self.collectionView.reloadData()
    }
    
}

