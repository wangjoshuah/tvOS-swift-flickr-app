//
//  SecondViewController.swift
//  tvOS-Flickr-App
//
//  Created by Josh Wang on 5/11/16.
//  Copyright © 2016 wangjoshuah. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CustomButtonPressed(sender: AnyObject) {
        // track conversion
        OptimizelyManager.optimizely!.trackEvent("pressed_button", forUser: OptimizelyManager.getUserId())
    }
}

