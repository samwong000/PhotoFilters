//
//  PhotoFrameworkViewController.swift
//  PhotoFilters
//
//  Created by Sam Wong on 15/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import UIKit
import Photos

class PhotoFrameworkViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    var assetFetchResults: PHFetchResult!
//    var assetCollection: PHAssetCollection!
    var imageManager: PHCachingImageManager!
    var assetCellSize: CGSize!
    var delegate : GalleryDelegate?
    var flowLayout : UICollectionViewFlowLayout!
    
    @IBOutlet var collectionView: UICollectionView!
    

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        self.imageManager = PHCachingImageManager()
        self.assetFetchResults = PHAsset.fetchAssetsWithOptions(nil)
        
        // Determine device scale, adjust asset cell size
        var scale = UIScreen.mainScreen().scale
        var cellSize = flowLayout.itemSize
        self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
        
        var pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        self.collectionView.addGestureRecognizer(pinch)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.backgroundColor = UIColor.whiteColor()
    }
    
    func handlePinch(pinch : UIPinchGestureRecognizer) {
        if pinch.state == UIGestureRecognizerState.Ended {
            println("UIGestureRecognizerState.Ended")
            println(pinch.velocity)
            self.collectionView.performBatchUpdates({ () -> Void in
                println("width = \(self.flowLayout.itemSize.width)")
                println("height = \(self.flowLayout.itemSize.height)")
                
                if pinch.velocity > 0 {
                    // enlarge it
                    if self.flowLayout.itemSize != CGSize(width: 100, height: 100) {
                        self.flowLayout.itemSize = CGSize(width: self.flowLayout.itemSize.width * 2, height: self.flowLayout.itemSize.height * 2)
                    }
                } else {
                    // shrink it
                    if self.flowLayout.itemSize != CGSize(width: 50, height: 50) {
                        self.flowLayout.itemSize = CGSize(width: self.flowLayout.itemSize.width * 0.5, height: self.flowLayout.itemSize.height * 0.5)
                    }
                }
            }, completion: nil )
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetFetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath) as PhotoFrameworkCell
        
        var currentTag = cell.tag + 1
        cell.tag = currentTag
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            
            if cell.tag == currentTag {
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        self.imageManager.requestImageDataForAsset(asset, options: nil) { (data : NSData!, string : String!, orientation : UIImageOrientation, object : [NSObject : AnyObject]!) -> Void in
            //transform into image
            var image = UIImage(data: data)
            //call delegate
            self.delegate?.didTapOnPicture(image)
            //dismiss view controller
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
}


