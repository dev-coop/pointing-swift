//
//  ReviewViewController.swift
//  Pointing
//
//  Created by Lucas Hutyler on 5/18/15.
//  Copyright (c) 2015 Upper Left Labs. All rights reserved.
//

import UIKit
import CoreLocation

class ReviewViewController: UIViewController {
    
    @IBOutlet var lblOffBy : UILabel!
    
    var headingDiff : Double!
    var currentLocation : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        if (abs(headingDiff)) > 180 {
            headingDiff = abs(headingDiff) - 360
        }
        lblOffBy.text = String(format: "You were off by %.2f degrees", abs(headingDiff))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Next button
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let gameVC = segue.destinationViewController as! GameViewController
        gameVC.currentLocation = currentLocation
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
