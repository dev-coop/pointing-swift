//
//  HomeViewController.swift
//  Pointing
//
//  Created by Lucas Hutyler on 5/18/15.
//  Copyright (c) 2015 Upper Left Labs. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var lblAcquiringLocation : UILabel!
    @IBOutlet var btnStartGame : UIButton!
    
    var locationManager : CLLocationManager!
    var currentLocation : CLLocation!
    var isAuthorized : Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        lblAcquiringLocation.hidden = false
        btnStartGame.hidden = true
        if (isAuthorized == true) {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Clicks
    
    @IBAction func clickStartRandom() {
        performSegueWithIdentifier("HomeToGame", sender: nil)
    }
    
    // MARK: Location
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            println("My Error: \(error)")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        currentLocation = locationArray.lastObject as! CLLocation
        var coord = currentLocation.coordinate
        println("New location: \(coord.latitude), \(coord.longitude)")
        
        locationManager.stopUpdatingLocation()
        lblAcquiringLocation.hidden = true
        btnStartGame.hidden = false
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        print("New heading: \(newHeading.trueHeading)")
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var locationStatus : NSString = "Not determined"
        
        switch status {
        case CLAuthorizationStatus.Restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.Denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.NotDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            self.isAuthorized = true
        }
        
        if (isAuthorized == true) {
            println("Location is Allowed")
            locationManager.startUpdatingLocation()
        } else {
            var alert = UIAlertController(title: nil, message: "Can't acquire location: \(locationStatus)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
            presentViewController(alert, animated: false, completion: nil)
            
            println("Denied access: \(locationStatus)")
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let gameVC = segue.destinationViewController as! GameViewController
        gameVC.currentLocation = currentLocation
    }
}
