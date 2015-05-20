//
//  ReviewViewController.swift
//  Pointing
//
//  Created by Lucas Hutyler on 5/18/15.
//  Copyright (c) 2015 Upper Left Labs. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
    
    @IBOutlet var lblOffBy : UILabel!
    
    var headingDiff : Double!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        lblOffBy.text = String(format: "You were off by %.2f degrees", headingDiff)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Clicks
    
    @IBAction func clickToHome() {
        navigationController?.popToRootViewControllerAnimated(true)
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
