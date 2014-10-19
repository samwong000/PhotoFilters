//
//  File.swift
//  PhotoFilters
//
//  Created by Sam Wong on 14/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import Foundation
import CoreData
import CoreImage

class CoreDataSeeder {
    var managedObjectContext : NSManagedObjectContext?
    
    init(context : NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func seedCoreData() {
        //add filters into core data
        
        var CIBloom = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CIBloom.name = "CIBloom"
        var CISepiaTone = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CISepiaTone.name = "CISepiaTone"
        var CIPixellate = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CIPixellate.name = "CIPixellate"
        var CIGaussianBlur = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CIGaussianBlur.name = "CIGaussianBlur"
        var CIGammaAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CIGammaAdjust.name = "CIGammaAdjust"
        var CIExposureAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CIExposureAdjust.name = "CIExposureAdjust"
        var CIPhotoEffectChrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CIPhotoEffectChrome.name = "CIPhotoEffectChrome"
        var CIPhotoEffectInstant = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CIPhotoEffectInstant.name = "CIPhotoEffectInstant"
        var CIPhotoEffectMono = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CIPhotoEffectMono.name = "CIPhotoEffectMono"
        var CIPhotoEffectNoir = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CIPhotoEffectNoir.name = "CIPhotoEffectNoir"
        var CIPhotoEffectTonal = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CIPhotoEffectTonal.name = "CIPhotoEffectTonal"
        var CIPhotoEffectTransfer = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext!) as Filter
        CIPhotoEffectTransfer.name = "CIPhotoEffectTransfer"
        
        var error : NSError?
        self.managedObjectContext?.save(&error)
        
        if error != nil {
            println(error?.localizedDescription)
        }
        
    }
    
}
