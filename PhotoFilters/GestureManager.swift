//
//  ImageGestureManager.swift
//  PhotoFilters
//
//  Created by Sam Wong on 16/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import UIKit

class GestureManager : NSObject {
    
    var collectionView : UICollectionView?
    var flowLayout : UICollectionViewFlowLayout?
    
    override init() {
        
    }
    
    func pinchAction(pinch : UIPinchGestureRecognizer) {
        println("pinchAction")
        
        if pinch.state == UIGestureRecognizerState.Ended {
            self.collectionView?.performBatchUpdates({ () -> Void in
                if pinch.velocity > 0 {
                    self.flowLayout!.itemSize = CGSize(width: self.flowLayout!.itemSize.width * 2, height: self.flowLayout!.itemSize.height * 2)
                } else {
                    self.flowLayout!.itemSize = CGSize(width: self.flowLayout!.itemSize.width * 0.5, height: self.flowLayout!.itemSize.height * 0.5)
                }
            }, completion: nil)
        }
    }
    
}
