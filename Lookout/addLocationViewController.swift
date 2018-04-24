//
//  addLocationViewController.swift
//  Lookout
//
//  Created by Ben Kolde on 4/12/18.
//  Copyright © 2018 benkolde. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Photos
import MapKit
import CoreLocation
import FirebaseStorage

class addNewLocationViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var locationManager = CLLocationManager()
   
    
    var ref: DatabaseReference!
    var imageURL: URL!

    
    
    @IBOutlet weak var uploadedImage: UIImageView!
    let imagePicker = UIImagePickerController()
    @IBAction func uploadImageAction(_ sender: Any) {
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var placeNameInput: UITextField!
    @IBOutlet weak var placeMap: MKMapView!
    
    var newLocationCoordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    @IBOutlet weak var placeStyleList: UILabel!
    @IBOutlet weak var placeStyleInput: UITextField!
    var styleArray = [String]()
    @IBAction func addPlaceStyleAction(_ sender: Any) {
        styleArray.append(placeStyleInput.text! + ",")
        placeStyleInput.text = ""
        
        print(styleArray)
        
        placeStyleList.text = String(describing: styleArray)
    }
    
    @IBOutlet weak var placeFeatureList: UILabel!
    @IBOutlet weak var placeFeatureInput: UITextField!
    var featureArray = [String]()
    @IBAction func addPlaceFeatureAction(_ sender: Any) {
        featureArray.append(placeFeatureInput.text! + ",")
        placeFeatureInput.text = ""
        placeFeatureList.text = "\(featureArray)"
    }
    
    @IBOutlet weak var placePriceControl: UISegmentedControl!
    
    @IBOutlet weak var placePriceInput: UITextField!
    
   
    func randomString(_ length: Int) -> String {
        
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Firebase Database
        //reference to database
        
        
        
        imagePicker.delegate = self
        placePriceInput.delegate = self
        placeStyleInput.delegate = self
        placeFeatureInput.delegate = self
        placeNameInput.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        
        
//        let annotation = MKPointAnnotation()
//        let centerCoordinate = CLLocationCoordinate2D(latitude: 39.5070, longitude:84.7452)
//        annotation.coordinate = centerCoordinate
//        annotation.title = "Title"
//        placeMap.addAnnotation(annotation)
        
        
        func showPriceInput() {
            switch placePriceControl.selectedSegmentIndex {
            case 0:
                print("input price")
            case 1:
                placePriceInput.text = "Free"
            default:
                break;
            }
        }
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+800)
        
        self.hideKeyboard()
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        var currentLocation: CLLocationCoordinate2D = (locationManager.location?.coordinate)!
        newLocationCoordinates = currentLocation
        
        print(newLocationCoordinates)
        let span = MKCoordinateSpanMake(0.0001, 0.0001)
        
        let region = MKCoordinateRegionMake(currentLocation, span)
        
        placeMap.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = currentLocation
        annotation.title = placeNameInput.text
       
        placeMap.addAnnotation(annotation)
        
        locationManager.stopUpdatingLocation()
    
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            uploadedImage.image = possibleImage
            
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            uploadedImage.image = possibleImage
        } else {
            return
        }
        
        
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when   'return' key pressed. return NO to ignore.
    {
        placeNameInput.resignFirstResponder()
        placePriceInput.resignFirstResponder()
        return false;
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    @IBAction func saveLocation(_ sender: Any) {
        //object
        ref = Database.database().reference()
        
//        var newLocation: NSDictionary = [
//            "name" : placeNameInput.text,
//            "addedByUser" : Auth.auth().currentUser?.uid,
//            "images" : [uploadedImage.image],
//            "style" : styleArray,
//            "features" : featureArray,
//            "coordinates" : newLocationCoordinates,
//            "price" : placePriceInput.text,
//        ]
        
        var data = Data()
        data = UIImageJPEGRepresentation(uploadedImage.image!, 0.8)!
        
        let imageRef = Storage.storage().reference().child("locationImages/" + randomString(20));
        
        _ = imageRef.putData(data, metadata: nil) { (metadata, error) in guard let metadata = metadata else {
            // uh oh an error occured
            print("uh oh")
            return
            }
            let downloadURL = metadata.downloadURL()
            self.imageURL = downloadURL!
            
            print(self.imageURL)
            
            //
            //            let image = ["url":downloadURL?.absoluteString]
            //
            //            let imageUpdate = ["/\(key)": image]
            //            self.ref.updateChildValues(imageUpdate)
            
            let key = self.ref.child("locations").childByAutoId().key
            let post = ["name": self.placeNameInput.text,
                        "addedByUser" : String(describing: Auth.auth().currentUser?.uid),
                        "images" : String(describing: self.imageURL.absoluteString),
                "style" : self.styleArray,
                "features" : self.featureArray,
                "coordinates" : String(describing: self.newLocationCoordinates),
                "price" : self.placePriceInput.text,
                ] as [String : Any]
            
            print(post)
            
            let childUpdates = ["/locations/\(key)": post,
                                ]
            self.ref.updateChildValues(childUpdates)
            
        }
        
        
        
        //images to storage
       
    
        
    }
    
    
}



extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}


