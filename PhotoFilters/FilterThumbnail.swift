//
//  FilterThumbnail.swift
//  PhotoFilters
//
//  Created by Sam Wong on 14/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import UIKIt

class FilterThumbnail {
    var originalThumbnail : UIImage
    var filteredThumbnail : UIImage?
    var imageQueue : NSOperationQueue?
    var gpuContext : CIContext
    var filter : CIFilter?
    var filterName : String
    
    var filteredImage : UIImage?
    
    init(name : String, thumbnail : UIImage, queue : NSOperationQueue, context : CIContext) {
        self.filterName = name
        self.originalThumbnail = thumbnail
        self.imageQueue = queue
        self.gpuContext = context
    }
    
    func generateThumbnail(completionHandler : (image : UIImage) -> (Void)) {
        
        self.imageQueue?.addOperationWithBlock({ () -> Void in
            //set up filter with CIImage
            var image = CIImage(image : self.originalThumbnail)
            var imageFilter = CIFilter(name: self.filterName)
            imageFilter.setDefaults()
            //specify that the output of the kernel is in this color space
            imageFilter.setValue(image, forKey: kCIInputImageKey)
            
            //generate the results
            var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
            //get the result's rectangles size
            var extent = result.extent()
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            
            //apply filter
            self.filter = imageFilter
            //convert CGIImage to UIImage
            self.filteredThumbnail = UIImage(CGImage: imageRef)
            
            //return to main thread
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(image : self.filteredThumbnail!)
            })
        })
    }
    
    func applyFilterToImage (image : UIImage, completionHandler : (filteredImage : UIImage) -> Void) {
        //Going to a different thread
        self.imageQueue?.addOperationWithBlock({ () -> Void in
            //Setting up the filter with a CIImage, changes UIImage to CIImage
            var image = CIImage(image: image)
            self.filter!.setValue(image, forKey: kCIInputImageKey)
            if self.filter!.name() == "CIBloom" {
                self.filter!.setValue(15.0, forKey: kCIInputRadiusKey)
                self.filter!.setValue(5.0, forKey: kCIInputIntensityKey)
            }
            
            //Generate the results
            var result = self.filter!.valueForKey(kCIOutputImageKey) as CIImage
            var extent = result.extent()
            //Filters in createCGImage
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            let filteredImage = UIImage(CGImage: imageRef)
            
            //Back to main queue to pass back the image
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(filteredImage: filteredImage)
            })
        })
    }
    

    
}
