//
//  locationObject.swift
//  Lookout
//
//  Created by Ben Kolde on 4/12/18.
//  Copyright © 2018 benkolde. All rights reserved.
//

import Foundation
import FirebaseDatabase
import UIKit
import CoreLocation

class locationObject  {
    
    var ref: DatabaseReference
    var title: String
    var name: String
    var addedByUser: String
    var images: [String]
    var style: [String]
    var features: [String]
    var coordinates: CLLocationCoordinate2D
    var price: String
    
    init (snapshot: DataSnapshot) {
        ref = snapshot.ref
        
        let data = snapshot.value as! Dictionary<String, String>
        ref = data["ref"] as! DatabaseReference
        title = data["title"]! as String
        name = data["name"]! as String
        addedByUser = data["addedByUser"]! as String
        images = data["images"] as! [String]
        style = data["style"] as! [String]
        features = data["features"] as! [String]
        coordinates = data["coordinaties"] as! CLLocationCoordinate2D
        price = data["Price"] as! String
    }
    
    
}

