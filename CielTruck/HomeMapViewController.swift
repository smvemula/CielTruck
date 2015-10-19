//
//  FirstViewController.swift
//  CielTruck
//
//  Created by Vemula, Manoj (Contractor) on 5/15/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI
import Firebase

class HomeMapViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var truckLocatorMapView : MKMapView!
    @IBOutlet var locationOptions : UISegmentedControl!
    @IBOutlet var addressTextfield : UITextField!
    @IBOutlet var editSaveButton : UIBarButtonItem!
    @IBOutlet var cancelButton : UIBarButtonItem!
    var ref : Firebase!
    var tempRef: Firebase!
    
    var isEditMode = false
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        self.addressTextfield.hidden = true
        switch sender.selectedSegmentIndex {
        case 0...1:
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveLocationUpdateNotification:", name: kLocationUpdateNotification, object: nil)
            UserLocation.manager.locationManager.startUpdatingLocation()
        default:
            self.addressTextfield.hidden = false
            self.addressTextfield.becomeFirstResponder()
            print("")
        }
    }
    
    @IBAction func cancel() {
        if self.isEditMode {
            self.isEditMode = false
            self.cancelButton.title = ""
            self.editSaveButton.title = "Edit"
            self.locationOptions.hidden = true
            self.addressTextfield.resignFirstResponder()
            self.addressTextfield.hidden = true
            //self.getTruckLocations()
        }
    }
    
    @IBAction func editsave() {
        if isEditMode {
            switch self.locationOptions.selectedSegmentIndex {
            case 0...1:
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                self.saveStoreDetailsInServerWithLocation(UserLocation.manager.locationManager.location!, address: "Current Locations")
            default:
                self.convertAddressToLatLon(self.addressTextfield.text!, save: true)
            }
            self.cancel()
        } else {
            self.locationOptions.selected = false
            self.cancelButton.title = "Cancel"
            self.editSaveButton.title = "Save"
            self.locationOptions.hidden = false
            self.isEditMode = true
        }
    }

    //var locations = [PFObject]()
    var mapAnnotation: MapAnnotation?
    //var mPFStoreObject: PFObject?
    
    //constants
    let kStoreProfileIDKey = "storeProfileID"
    let kLocationUpdateNotification = "LocationUpdateNotification"
    let kCoordinate = "Coordinate"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        truckLocatorMapView.delegate = self
        //ref.keepSynced(true)
        Firebase.defaultConfig().persistenceEnabled = true
        ref = Firebase(url:"https://cieldessertbar.firebaseio.com/Locations/Truck1")
        tempRef = Firebase(url: "https://bet-on-dev-test.firebaseio.com/users/1089952011014852/bets")
        
        //self.printBetOnQueries()
        self.getTruckLocations()
    }
    
    
    func printBetOnQueries() {
        tempRef.queryOrderedByChild("game_id").queryEqualToValue(2015091401).observeEventType(.Value, withBlock: { snapshot in
            //print("matching key : Value \(snapshot.value)")
            //self.updateLocationOnMap(snapshot)
            }, withCancelBlock: { error in
                print(error.description)
        })
        tempRef.queryOrderedByChild("bet_amount").queryLimitedToLast(2).observeEventType(.Value, withBlock: { snapshot in
            //print("Sorted by bets Value \(snapshot.value)")
            //self.updateLocationOnMap(snapshot)
            }, withCancelBlock: { error in
                print(error.description)
        })
        tempRef = Firebase(url: "https://bet-on-dev-test.firebaseio.com/games/nfl/schedule")
        tempRef.queryOrderedByChild("week").queryEqualToValue("TB", childKey: "away").queryLimitedToLast(5).observeEventType(.Value, withBlock: { snapshot in
            print("Games Matching Week \(snapshot.value)")
            if let matches = snapshot.value as? [NSDictionary] {
                self.tempRef = Firebase(url: "https://bet-on-dev-test.firebaseio.com/users/1089952011014852/bets")
                for each  in matches {
                    if let matchid = each["2016010311"] as? String {
                        self.tempRef.queryOrderedByChild("game_id").queryEqualToValue(matchid).observeEventType(.Value, withBlock: { snapshot1 in
                            print("\(matchid) by bets Value \(snapshot1.value)")
                            //self.updateLocationOnMap(snapshot)
                            }, withCancelBlock: { error in
                                print(error.description)
                        })
                    }
                }
            }
            //self.updateLocationOnMap(snapshot)
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func updateLocationOnMap(snapshot: FDataSnapshot) {
        if let truck1 = snapshot.value as? NSDictionary {
            if let name =  truck1["name"] as? String {
                UserLocation.manager.truckName = name
            }
            
            if let sub = truck1["hours"] as? String {
                UserLocation.manager.truckHours = sub
            }
            if let lat = truck1["latitude"] as? Double {
                if let long = truck1["longitude"] as? Double {
                    let location = CLLocation(latitude: lat, longitude: long)
                    self.convertLatLonToAddress(location)
                }
            }
        }
    }
    
    func getTruckLocations() {
        
        // Attach a closure to read the data at our posts reference
        ref.observeEventType(.Value, withBlock: { snapshot in
            //print("Inial Value \(snapshot.value)")
            self.updateLocationOnMap(snapshot)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.truckLocatorMapView.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK: UITextFieldDelegate Methods
extension HomeMapViewController {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let textExists = textField.text {
            let address = textExists.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.convertAddressToLatLon(address, save: false)
        }
        return true
    }
    
    func convertAddressToLatLon(aAddress: String, save: Bool) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(aAddress, completionHandler: {(placemarks, error) -> Void in
            let placemark = placemarks?.first
            let location = placemark?.location
            if let _ = location {
                self.setLatLonInMap(location!)
                if save {
                    self.saveStoreDetailsInServerWithLocation(location!, address: aAddress)
                }
            } else {
                UIAlertView.showAlertView("Invalid Location", text: "Please re enter again.", vc: self)
                print("cannot find location for this text")
            }
        })
    }
    
    func convertLatLonToAddress(aLocation: CLLocation)
    {
        self.setLatLonInMap(aLocation)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(aLocation, completionHandler: {(placemarks, error) -> Void in
            print("finding address for location")
            if error != nil {
                print(error)
            } else {
                let placemark = placemarks?.last
                self.addressTextfield.text = ABCreateStringWithAddressDictionary(placemark!.addressDictionary!, false)
            }
            })
    }

    func setLatLonInMap(aLocation: CLLocation)
    {
    //[self saveStoreDetailsInServerWithLocation:aLocation];
        self.addMapAnnotationWithCoordinates(aLocation.coordinate)
    }
    
    func addMapAnnotationWithCoordinates(aCordinates: CLLocationCoordinate2D)
    {
        if let exists = self.mapAnnotation {
            self.truckLocatorMapView.removeAnnotation(exists)
        }
        var title = ""
        var subTitle = ""
        if let name = UserLocation.manager.truckName {
            title = name
        }
        
        if let sub = UserLocation.manager.truckHours {
            subTitle = sub
        }
        let aMapAnnotation = MapAnnotation(coordinate: aCordinates, title: title, subtitle: subTitle)
        self.mapAnnotation = aMapAnnotation
        
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        
        let viewRegion = MKCoordinateRegion(center: aCordinates, span: span)
        
        self.truckLocatorMapView.setRegion(viewRegion, animated: true)
        self.truckLocatorMapView.addAnnotation(aMapAnnotation)
    }
    
    func saveStoreDetailsInServerWithLocation(alocation: CLLocation, address: String)
    {
        var newLocation :[String : AnyObject] = ["latitude" : alocation.coordinate.latitude,"longitude": alocation.coordinate.longitude]
        if let name = UserLocation.manager.truckName {
            newLocation["name"] = name
        } else {
            newLocation["name"] = "Udaya Truck#1"
        }
        
        if let sub = UserLocation.manager.truckHours {
            newLocation["hours"] = sub
        } else {
            newLocation["hours"] = "6:00PM - 11.30PM"
        }
        ref.setValue(newLocation)
    }
    
    func receiveLocationUpdateNotification(notification: NSNotification)
    {
        if let aDict = notification.userInfo {
            if self.locationOptions.selectedSegmentIndex != 1 {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: kLocationUpdateNotification, object: nil)
                UserLocation.manager.locationManager.stopUpdatingLocation()
            }
            if let clLocation = aDict[kCoordinate] as? CLLocation {
                self.convertLatLonToAddress(clLocation)
            }
        }
    }
}

//MARK: MKMapViewDelegateMethods

extension HomeMapViewController {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        
        if let _ = annotation as? MKUserLocation {
            return nil
        } else {
            let identifier = "myAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            if annotationView != nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
        
            annotationView?.image = UIImage(named: "cupcake.png")
            //annotationView?.pinColor = MKPinAnnotationColor.Green
            
            //annotationView?.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            return annotationView
        }
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for each in views {
            self.truckLocatorMapView.selectAnnotation(each.annotation!, animated: true)
        }
    }
}


class Artwork: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}

