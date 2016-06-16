//
//  OptimizelyManager.swift
//  tvOS-Flickr-App
//
//  Created by Josh Wang on 6/7/16.
//  Copyright © 2016 wangjoshuah. All rights reserved.
//

import Foundation

class OptimizelyManager {
    
    static var optimizely: Optimizely?
    static var userId: String?
    
    static func getUserId() -> String {
        if ((OptimizelyManager.userId == nil)) {
            OptimizelyManager.userId = NSDate.timeIntervalSinceReferenceDate().description;
        }
        return OptimizelyManager.userId!
    }
    
    static func resetUserId() -> Void {
        OptimizelyManager.userId = nil
    }
}