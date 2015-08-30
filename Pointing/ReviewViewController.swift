//
//  ReviewViewController.swift
//  Pointing
//
//  Created by Lucas Hutyler on 5/18/15.
//  Copyright (c) 2015 Upper Left Labs. All rights reserved.
//

import UIKit
import CoreLocation


let healthBarWidth: Int = 20
let healthBarHeight: Int = 200

class ReviewViewController: UIViewController {

    @IBOutlet weak var healthContainer : UIView!
    @IBOutlet var playerHealthBar : UIView!
    @IBOutlet weak var healthLabel : UILabel!
    @IBOutlet var lblOffBy : UILabel!
    
    var headingDiff : Double!
    var currentLocation : CLLocation!
    var playerHealth : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        if (abs(headingDiff)) > 180 {
            headingDiff = abs(headingDiff) - 360
        }
        lblOffBy.text = String(format: "You were off by %.2f degrees", abs(headingDiff))
        
        updateHealthbar(Int(abs(headingDiff)))
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Next button
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let gameVC = segue.destinationViewController as! GameViewController
        gameVC.currentLocation = currentLocation
        gameVC.playerHealth = Int(self.playerHealth)
    }
    
    func updateHealthbar(wound: Int) {
        healthContainer.layer.borderColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0).CGColor
        healthContainer.layer.borderWidth = 3.0
        
        self.playerHealth = self.playerHealth - wound

        self.playerHealthBar.frame.size.height = CGFloat(self.playerHealth*2)
        var offset = healthBarHeight - (self.playerHealth*2)
        self.playerHealthBar.frame.offset(dx: 0, dy: CGFloat(offset))
        
        // You'll need these two methods if you are using auto layout and swift 1.2
        playerHealthBar.setTranslatesAutoresizingMaskIntoConstraints(true)
        playerHealthBar.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin
        
        healthLabel.text = String(self.playerHealth)
    }

}
