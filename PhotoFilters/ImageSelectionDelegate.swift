//
//  ImageSelectionDelegate.swift
//  PhotoFilters
//
//  Created by Sam Wong on 16/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import Foundation
import UIKit

protocol ImageSelectionDelegate {
    func controller(controller: UIViewController, didSelectImage image: UIImage)
    
}