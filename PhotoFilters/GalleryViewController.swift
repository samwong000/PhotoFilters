//
//  PhotoViewController.swift
//  PhotoFilters
//
//  Created by Sam Wong on 13/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import UIKit

//add protocol. the delegate passes the selected image to main view controller
protocol GalleryDelegate {
    func didTapOnPicture(image : UIImage)
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = [UIImage]()
    var delegate : GalleryDelegate?
    var flowLayout : UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        
//        var gestureManager = GestureManager()
//        gestureManager.collectionView = self.collectionView
//        gestureManager.flowLayout = self.flowLayout
        
        var pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        self.collectionView.addGestureRecognizer(pinch)
        
//        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//            flowLayout.itemSize = CGSizeMake(200.0, 200.0)
//            self.collectionView.collectionViewLayout = flowLayout
//        } else {
//            flowLayout.itemSize = CGSizeMake(50.0, 50.0)
//            self.collectionView.collectionViewLayout = flowLayout
//        }
        
        var image1 = UIImage(named: "photo2.jpg")
        var image2 = UIImage(named: "photo3.jpg")
        var image3 = UIImage(named: "photo4.jpg")
        var image4 = UIImage(named: "photo5.jpg")
    
        self.images.append(image1)
        self.images.append(image2)
        self.images.append(image3)
        self.images.append(image4)
        
    
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        //"http://lorempixel.com/400/400/"
        
    }
    
    func handlePinch(pinch : UIPinchGestureRecognizer) {
        if pinch.state == UIGestureRecognizerState.Ended {
            println("UIGestureRecognizerState.Ended")
            println(pinch.velocity)
            self.collectionView.performBatchUpdates({ () -> Void in
                
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
        return self.images.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //dequeue
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        cell.imageView.image = self.images[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("GalleryDelegate.collectionView")
        self.delegate?.didTapOnPicture(self.images[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView : UICollectionReusableView
        
        // header code
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HEADER_VIEW", forIndexPath: indexPath) as ImageHeaderView
            headerView.backgroundColor = UIColor.blueColor()
            headerView.titleLabel.text = "Title"
            reusableView = headerView
            return reusableView
        } else {
            // footer code
            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "FOOTER_VIEW", forIndexPath: indexPath) as ImageFooterView
            footerView.backgroundColor = UIColor.redColor()
            footerView.descriptionLabel.text = "Description"
            reusableView = footerView
            return reusableView
        }
        
    }
    
    
}
