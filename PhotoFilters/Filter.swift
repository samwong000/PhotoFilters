//
//  Filter.swift
//  PhotoFilters
//
//  Created by Sam Wong on 14/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import Foundation
import CoreData

class Filter: NSManagedObject {

    @NSManaged var favourite: NSNumber
    @NSManaged var name: String

}
