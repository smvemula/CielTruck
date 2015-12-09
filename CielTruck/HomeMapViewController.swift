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
    var ref : Firebase!
    
    var isEditMode = false
    var isAdmin = false
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        self.addressTextfield.hidden = true
        if isAdmin {
            switch sender.selectedSegmentIndex {
            case 0...1:
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveLocationUpdateNotification:", name: kLocationUpdateNotification, object: nil)
                UserLocation.manager.locationManager.startUpdatingLocation()
            default:
                self.addressTextfield.hidden = false
                self.addressTextfield.becomeFirstResponder()
                print("")
            }
        } else {
            switch sender.selectedSegmentIndex {
            case 0:
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveLocationUpdateNotification:", name: kLocationUpdateNotification, object: nil)
                UserLocation.manager.locationManager.startUpdatingLocation()
            default:
                self.addressTextfield.hidden = false
                self.addressTextfield.becomeFirstResponder()
                print("")
            }
        }
    }
    
    @IBAction func cancel() {
        if self.isEditMode {
            self.isEditMode = false
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "map"), style: UIBarButtonItemStyle.Plain, target: self, action: "editsave")
            self.locationOptions.hidden = true
            self.addressTextfield.resignFirstResponder()
            self.addressTextfield.hidden = true
            if isAdmin {
                self.getTruckLocations()
                self.locationOptions.selectedSegmentIndex = UISegmentedControlNoSegment
            } else {
                
            }
        }
    }
    
    @IBAction func editsave() {
        if isAdmin {
            if isEditMode {
                switch self.locationOptions.selectedSegmentIndex {
                case 0...1:
                    self.saveStoreDetailsInServerWithLocation(UserLocation.manager.locationManager.location!, address: "Current Locations")
                default:
                    self.convertAddressToLatLon(self.addressTextfield.text!, save: true)
                }
                self.cancel()
            } else {
                self.locationOptions.selectedSegmentIndex = UISegmentedControlNoSegment
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel")
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "editsave")
                self.locationOptions.hidden = false
                self.isEditMode = true
            }
        } else {
            if isEditMode {
                switch self.locationOptions.selectedSegmentIndex {
                case 0:
                    print("Show user with Trucks around for current location")
                    NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "UsercustomAddress")
                    self.cancel()
                default:
                    self.convertAddressToLatLon(self.addressTextfield.text!, save: false)
                    print("Show user with Trucks around for Custom location")
                }
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "editsave")
                self.locationOptions.hidden = false
                self.isEditMode = true
                self.addressTextfield.hidden = self.locationOptions.selectedSegmentIndex == 1 ? false : true
            }
        }
    }

    var mapAnnotation: MapAnnotation?
    var userAnnotation: MapAnnotation?
    
    //constants
    let kStoreProfileIDKey = "storeProfileID"
    let kLocationUpdateNotification = "LocationUpdateNotification"
    let kCoordinate = "Coordinate"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        truckLocatorMapView.delegate = self
        Firebase.defaultConfig().persistenceEnabled = true
        ref = Firebase(url:"https://cieldessertbar.firebaseio.com/Locations/Truck1")
        
        self.navigationController?.navigationBar.barTintColor = UIColor.darkPinkCielColor
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "map"), style: UIBarButtonItemStyle.Plain, target: self, action: "editsave")
        self.locationOptions.tintColor = UIColor.darkPinkCielColor
        self.view.backgroundColor = UIColor.cielBackgroundColor
        self.getTruckLocations()
        
        if isAdmin {
            self.locationOptions.setTitle("Current", forSegmentAtIndex: 0)
            self.locationOptions.setTitle("Keep Updating", forSegmentAtIndex: 1)
            self.locationOptions.setTitle("Use Address", forSegmentAtIndex: 2)
        } else {
            self.locationOptions.removeAllSegments()
            self.locationOptions.insertSegmentWithTitle("Current Location", atIndex: 0, animated: false)
            self.locationOptions.insertSegmentWithTitle("Use Address", atIndex: 1, animated: false)
            if let exists = NSUserDefaults.standardUserDefaults().objectForKey("UsercustomAddress") as? String {
                self.convertAddressToLatLon(exists, save: false)
                self.locationOptions.selectedSegmentIndex = 1
            } else {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveLocationUpdateNotification:", name: kLocationUpdateNotification, object: nil)
                UserLocation.manager.locationManager.startUpdatingLocation()
                self.locationOptions.selectedSegmentIndex = 0
            }
        }
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
                if self.isAdmin {
                    self.setLatLonInMap(location!)
                    //self.cancel()
                } else {
                    self.cancel()
                    self.addUserAnnotationWithCoordinates(location!)
                    NSUserDefaults.standardUserDefaults().setValue(aAddress, forKey: "UsercustomAddress")
                    UserLocation.manager.locationManager.stopUpdatingLocation()
                }
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
        self.addTruckAnnotationWithCoordinates(aLocation.coordinate)
    }
    
    func addUserAnnotationWithCoordinates(aLocation: CLLocation)
    {
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
        
        if let exists = self.userAnnotation {
            self.truckLocatorMapView.removeAnnotation(exists)
        }

        let aMapAnnotation = MapAnnotation(coordinate: aLocation.coordinate, title: "Me", subtitle: self.locationOptions.selectedSegmentIndex == 0 ? "Current Location" : self.addressTextfield.text!)
        self.userAnnotation = aMapAnnotation
        
        if let exists = self.mapAnnotation {
//            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
//            let viewRegion = MKCoordinateRegion (center: exists.coordinate, span: span)
//            self.truckLocatorMapView.setRegion(viewRegion, animated: true)
//            
            self.truckLocatorMapView.showAnnotations([aMapAnnotation, exists], animated: true)
        } else {
            
        }
    }
    
    func addTruckAnnotationWithCoordinates(aCordinates: CLLocationCoordinate2D)
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
            newLocation["name"] = "Ciel Truck"
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
            if self.locationOptions.selectedSegmentIndex != 1 && isAdmin {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: kLocationUpdateNotification, object: nil)
                UserLocation.manager.locationManager.stopUpdatingLocation()
            }
            if let clLocation = aDict[kCoordinate] as? CLLocation {
                if isAdmin {
                    self.convertLatLonToAddress(clLocation)
                } else {
                    self.addUserAnnotationWithCoordinates(clLocation)
                }
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
        
            annotationView?.canShowCallout = true
            
            //annotationView?.rightCalloutAccessoryView =
            return annotationView
        }
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for each in views {
            each.tintColor = UIColor.darkPinkCielColor
            if each.annotation!.title!! == "Me" {
                each.image = UIImage(named: "userpin")?.tintWithColor(UIColor.darkPinkCielColor)
            } else {
                each.image = UIImage(named: "Truck")?.tintWithColor(UIColor.darkPinkCielColor)
                each.canShowCallout = true
                each.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
                self.truckLocatorMapView.selectAnnotation(each.annotation!, animated: true)
            }
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let truckFeatures = UIAlertController(title: "Ciel Truck", message: "Would you like to contact us?", preferredStyle: UIAlertControllerStyle.Alert)
        truckFeatures.view.tintColor = UIColor.darkPinkCielColor
        
       // truckFeatures.view.
        
        let call = UIAlertAction(title: "Call Ciel Truck", style: UIAlertActionStyle.Default, handler: { action in
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://+917674084729")!)
        })
        truckFeatures.addAction(call)
        
        let order = UIAlertAction(title: "Order & Pick up", style: UIAlertActionStyle.Default, handler: { action in
            if let tab = self.tabBarController {
                NSNotificationCenter.defaultCenter().postNotificationName("order", object: nil, userInfo: nil)
                tab.selectedIndex = 1
            }
        })
        truckFeatures.addAction(order)
        
        let directions = UIAlertAction(title: "Get Directions", style: UIAlertActionStyle.Default, handler: { action in
            let directVia = UIAlertController(title: "Show Directions with", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            directVia.view.tintColor = UIColor.darkPinkCielColor
            // truckFeatures.view.
            let google = UIAlertAction(title: "Google Maps", style: UIAlertActionStyle.Default, handler: { action in
                UIApplication.sharedApplication().openURL(NSURL(string: "comgooglemaps://?saddr=\(self.userAnnotation!.coordinate.latitude),\(self.userAnnotation!.coordinate.longitude)&daddr=\(self.mapAnnotation!.coordinate.latitude),\(self.mapAnnotation!.coordinate.longitude)&directionsmode=driving")!)
            })
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) {
                directVia.addAction(google)
            }
            let apple = UIAlertAction(title: "Apple Maps", style: UIAlertActionStyle.Default, handler: { action in
                UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?saddr=\(self.userAnnotation!.coordinate.latitude),\(self.userAnnotation!.coordinate.longitude)&daddr=\(self.mapAnnotation!.coordinate.latitude),\(self.mapAnnotation!.coordinate.longitude)&dirflg=d")!)
            })
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "http://maps.apple.com/")!) {
                directVia.addAction(apple)
            }
            let nothing = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            })
            directVia.addAction(nothing)
            self.presentViewController(directVia, animated: true, completion: {
                directVia.view.tintColor = UIColor.darkPinkCielColor
            })
        })
        truckFeatures.addAction(directions)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
        })
        truckFeatures.addAction(cancel)
        
        self.presentViewController(truckFeatures, animated: true, completion: {
            truckFeatures.view.tintColor = UIColor.darkPinkCielColor
        })
    }
    
    func showDirections() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.userAnnotation!.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.mapAnnotation!.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .Automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.truckLocatorMapView.addOverlay(route.polyline)
                self.truckLocatorMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        return renderer
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

