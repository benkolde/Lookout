//
//  FirstViewController.swift
//  Lookout
//
//  Created by Ben Kolde on 4/12/18.
//  Copyright © 2018 benkolde. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import CoreLocation
import Alamofire
import AlamofireImage

class protoCell: UICollectionViewCell, CLLocationManagerDelegate {
    
    @IBOutlet weak var nearbyLocationImage: UIImageView!
    @IBOutlet weak var nearbyLocationName: UILabel!
}
class nearbyProtoCell: UICollectionViewCell, CLLocationManagerDelegate {
    @IBOutlet weak var nearbyImage: UIImageView!
    @IBOutlet weak var nearbyName: UILabel!
    @IBOutlet weak var nearbyDistanceFromMe: UILabel!

}


//
class FirstViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    @IBOutlet weak var nearbyCollection: UICollectionView!
    @IBOutlet weak var nearbyLocation: UICollectionView!
    
    
    var locationManager = CLLocationManager()
    
    var justForYouLocation = [String:Any]()
    var justForYouArray = [[String:Any]]()

    var justForYouLocationNameArray = [String]()
    var justForYouLocationImageArray = [UIImage]()
    
    var ref: DatabaseReference!
    
    func loadJustForYou() {
        let ref = Database.database().reference().child("locations")

        
        ref.observe(.childAdded, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String
            var justForYouImageURL = value?["images"] as? String
            
           
            
            self.justForYouLocationNameArray.append(name!)
            
            
            print(self.justForYouLocationNameArray.count)
            self.nearbyCollection.reloadData()
        //images
            
            
            
            Alamofire.request(justForYouImageURL!).responseImage { response in
                if var justForYouImage = response.result.value {
                    self.justForYouLocationImageArray.append(justForYouImage)
                    
                    
                        print("image was uploaded")
                        print(justForYouImage)
                    
                    
                    var loadedLocation: NSDictionary = [
                        "name":name,
                        "images":justForYouImage,
                    ]
                    
                    self.justForYouLocation = loadedLocation as! [String : Any]
                    
                    self.justForYouArray.append(self.justForYouLocation)
                    
                    print(self.justForYouLocation)
                    
                    self.nearbyCollection.reloadData()
                    
                }
            }
            
            //justForYouLocationImageArray.append(justForYouImage)
            
            
            print(justForYouImageURL)
            
            //self.justForYouLocationImageArray.append(imageFromURL)
        
        
        })
        
        //images
        
        

        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        nearbyCollection.delegate = self as UICollectionViewDelegate
        nearbyCollection.dataSource = self as UICollectionViewDataSource
        nearbyLocation.delegate = self as UICollectionViewDelegate
        nearbyLocation.dataSource = self as UICollectionViewDataSource
        
        self.view.addSubview(nearbyCollection)
        self.view.addSubview(nearbyLocation)
        
        loadJustForYou()
        
        locationManager.delegate = self as? CLLocationManagerDelegate
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.stopUpdatingLocation()
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.nearbyCollection {
//        return nearbyLocations.count
            return justForYouArray.count
        }
        return 1
    }
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.nearbyCollection {
            let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "protoCell", for: indexPath) as! protoCell
            
            cellA.nearbyLocationName.text = justForYouArray[indexPath.row]["name"] as! String
            cellA.nearbyLocationImage.image = justForYouArray[indexPath.row]["images"] as? UIImage
            
            // Set up cell
            return cellA
        
        } else {
            let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "nearbyProtoCell", for: indexPath) as! nearbyProtoCell
            
            let distanceToNearbyLocation = CLLocation(latitude: 36.1627, longitude: 86.7816)
            var distanceToBarista = baristaLocation.distance(from: locationManager.location!)
            
            
            //convert to miles
            distanceToBarista = distanceToBarista/1609.344
            
            //round
            distanceToBarista = round(distanceToBarista)
            
            cellB.nearbyName.text = "Barista Parlor"
            cellB.nearbyDistanceFromMe.text = String(distanceToBarista) + " mi"
            
            // ...Set up cell
            
            return cellB
        }
    }
    
   
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddNewLocationViewController" {
            let destination = segue.destination as? addNewLocationViewController
            
            destination?.locationManager = locationManager
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

