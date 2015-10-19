//
//  UserLocation.swift
//  CielTruck
//
//  Created by Vemula, Manoj (Contractor) on 9/22/15.
//  Copyright © 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class UserLocation: NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var truckID: String?
    var truckName: String?
    var truckHours: String?
    
    // You can access the lat and long by calling:
    // currentLocation2d.latitude, etc
    
    var currentLocation2d:CLLocationCoordinate2D?
    
    
    class var manager: UserLocation {
        return SharedUserLocation
    }
    
    override init () {
        super.init()
        if self.locationManager.respondsToSelector(Selector("requestAlwaysAuthorization")) {
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 1
        //self.locationManager.startUpdatingLocation()
    }
    
    // Location Manager Delegate stuff
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
       // locationManager.stopUpdatingLocation()
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        print(coord.latitude)
        print(coord.longitude)
        if let exists = manager.location {
            self.currentLocation2d = exists.coordinate
            NSNotificationCenter.defaultCenter().postNotificationName("LocationUpdateNotification", object: nil, userInfo:["Coordinate":exists])
        }
    }
    
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            var shouldIAllow = false
            
            switch status {
            case CLAuthorizationStatus.Restricted:
                print("Restricted Access to location")
            case CLAuthorizationStatus.Denied:
                print("User denied access to location")
            case CLAuthorizationStatus.NotDetermined:
                print("Status not determined")
            default:
                print("Allowed to location Access")
                shouldIAllow = true
            }
            NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
            if (shouldIAllow == true) {
                NSLog("Location to Allowed")
                // Start location services
                //locationManager.startUpdatingLocation()
            } else {
                NSLog("Denied access: \(status)")
            }
    }
}

let SharedUserLocation = UserLocation()