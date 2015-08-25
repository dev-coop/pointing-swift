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
    
    @IBOutlet weak var mySlider: UISlider!
    @IBOutlet var lblCurrentHeading : UILabel!
    @IBOutlet var lblSliderHeading : UILabel!
    @IBOutlet var btnSubmit : UIButton!
//    @IBOutlet var lblAcquiringLocation : UILabel!
    @IBOutlet var lblTimeRemaining : UILabel!
    @IBOutlet var lblLocationName : UILabel!
    @IBOutlet var imgArrow : UIImageView!
    
    var locationManager : CLLocationManager!
    var observer : NSObjectProtocol!
    var currentLocation : CLLocation!
    var calculatedHeading : Double!
    var currentHeading : Double! = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        initLocationManager()
        acquireLocationToCompare()
//      mySlider.hidden = true
        
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
        performSegueWithIdentifier("GameToReview", sender: nil)
    }
    
    @IBAction func changedSlider(slider: UISlider) {
        // Update rotation of arrow
        let angle = CGFloat(slider.value) * CGFloat(M_PI) / CGFloat(slider.maximumValue)
        imgArrow.transform = CGAffineTransformMakeRotation(angle)
        
        // Update degrees
        currentHeading = Double(slider.value)
        lblSliderHeading.text = String(format: "%.1f °", currentHeading)
    }
    
    // MARK: - Private
    
    func acquireLocationToCompare() {
        var currentCoord = self.currentLocation.coordinate
        var url = "http://api.getpointing.com/v1/locations?lat=\(currentCoord.latitude)&lng=\(currentCoord.longitude)"
        Alamofire.request(.GET, url).responseJSON(options: .AllowFragments) { (request, response, JSON, error) -> Void in
            if ((error) != nil) {
                println("Error acquiring locations: \(error)")
            } else {
                let locs = JSON as! [AnyObject]
                let firstLoc: AnyObject = locs[0]
                
                let firstLocID      = firstLoc["id"] as! Int
                let firstLocName    = firstLoc["name"] as! String
                let firstLocAddress = firstLoc["address"] as! String
                let firstLocLat     = firstLoc["lat"] as! Double
                let firstLocLng     = firstLoc["lng"] as! Double
                let firstLocAlt     = firstLoc["elevation"] as! Double
                
                self.lblLocationName.text = firstLocName
                
                var destCoord = CLLocationCoordinate2DMake(firstLocLat, firstLocLng)
                self.calculatedHeading = self.getBearingBetweenTwoPoints1(currentCoord, point2: destCoord)
                println("coorentCoord: \(currentCoord.latitude)")
                println("Calculated heading: \(self.calculatedHeading)")
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
//      print("New heading: \(newHeading.trueHeading)")
        let angle = CGFloat(newHeading.trueHeading) * CGFloat(M_PI) / CGFloat(360)
        imgArrow.transform = CGAffineTransformMakeRotation(angle*2)
        currentHeading = newHeading.trueHeading
        lblCurrentHeading.text = String(format: "%.1f °", currentHeading)
    }
    
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
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let reviewVC = segue.destinationViewController as! ReviewViewController
        let headingDiff = abs(currentHeading - calculatedHeading)
        println("Prepare for segue with heading diff: \(headingDiff)")
        reviewVC.headingDiff = headingDiff
        reviewVC.currentLocation = currentLocation

    }
    
    // MARK: - Helper functions
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    func getBearingBetweenTwoPoints1(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
        // Credit where due: http://stackoverflow.com/questions/26998029/calculating-bearing-between-two-cllocation-points-in-swift
        
        let lat1 = degreesToRadians(point1.latitude)
        let lon1 = degreesToRadians(point1.longitude)
        
        let lat2 = degreesToRadians(point2.latitude);
        let lon2 = degreesToRadians(point2.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        // Converting (-180, 0) to (180, 360)
//        var degreesBearing = radiansToDegrees(radiansBearing)
//        if (degreesBearing < 0) {
//            degreesBearing += 360
//        }
        
        return radiansToDegrees(radiansBearing)
    }
}
