//
//  GameViewController.swift
//  Pointing
//
//  Created by Lucas Hutyler on 5/18/15.
//  Copyright (c) 2015 Upper Left Labs. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class GameViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var lblCurrentHeading : UILabel!
    @IBOutlet var btnSubmit : UIButton!
    @IBOutlet var lblAcquiringLocation : UILabel!
    
    var locationManager : CLLocationManager!
    var observer : NSObjectProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        initLocationManager()
        acquireLocationToCompare()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Go to root if user hits home button...
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        observer = notificationCenter.addObserverForName("EnterBackground", object: nil, queue: mainQueue) { (_) -> Void in
            navigationController?.popToRootViewControllerAnimated(false)
        }
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(observer);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Clicks
    
    @IBAction func clickSubmit() {
        // TODO: Compare to proper heading and move on to Review
        performSegueWithIdentifier("GameToReview", sender: nil)
    }
    
    // MARK: - Private
    
    func acquireLocationToCompare() {
        Alamofire.request(.GET, "http://api.getpointing.com/v1/locations").responseJSON(options: .AllowFragments) { (request, response, JSON, error) -> Void in
            if ((error) != nil) {
                println("Error acquiring locations: \(error)")
            } else {
                let locs = JSON as! NSArray
                let firstLoc = locs[0] as! NSArray
                
                let firstLocID = firstLoc[0] as! NSInteger
                let firstLocName = firstLoc[1] as! NSString
                let firstLocAddress = firstLoc[2] as! NSString
                let firstLocLat = firstLoc[3] as! CGFloat
                let firstLocLng = firstLoc[4] as! CGFloat
                let firstLocAlt = firstLoc[5] as! CGFloat
                
                println("First loc: \(firstLocName) (\(firstLocLat), \(firstLocLng))")
            }
        }
    }
    
    // MARK: - Location
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingHeading()
        if ((error) != nil) {
            println("My Error: \(error)")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        print("New heading: \(newHeading.trueHeading)")
    }
    
    // authorization status
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
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
            shouldIAllow = true
        }
        
        if (shouldIAllow == true) {
            println("Location is Allowed")
            locationManager.startUpdatingHeading()
        } else {
            var alert = UIAlertController(title: nil, message: "Can't acquire location: \(locationStatus)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
            presentViewController(alert, animated: false, completion: nil)
            
            println("Denied access: \(locationStatus)")
        }
    }
}
