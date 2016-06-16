//
//  AppDelegate.swift
//  tvOS-Flickr-App
//
//  Created by Josh Wang on 5/11/16.
//  Copyright © 2016 wangjoshuah. All rights reserved.
//

import UIKit
import FlickrKit
import Alamofire
import Darwin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    static var photoURLs: [NSURL]!
    static var images: [UIImage]!
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print("application did finish launching with options")
        AppDelegate.photoURLs = []
        AppDelegate.images = []
        
        // Override point for customization after application launch.
        FlickrKit.sharedFlickrKit().initializeWithAPIKey(PersonalConstants.FLICKR_KEY, sharedSecret: PersonalConstants.FLICKR_SECRET);
        let url: NSURL = NSURL(string: "https://cdn.optimizely.com/json/6184430073.json")!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        let downloadedDataFile: NSData;
        do {
            // download datafile
            downloadedDataFile = try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
            // start optimizely with datafile
            OptimizelyManager.optimizely = Optimizely.initWithBuilderBlock { (builder) -> Void in
                builder.dataFile = downloadedDataFile;
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        downloadImages()
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
    }
    
    func downloadImages() {
        let flickrPhotoSearchText = FKFlickrPhotosSearch()
        flickrPhotoSearchText.text = "cat dog"
        flickrPhotoSearchText.per_page = "1"
        flickrPhotoSearchText.safe_search = "1"
        flickrPhotoSearchText.content_type = "1"
        flickrPhotoSearchText.sort = "interestingness-desc";
        
        
        // Bucket user into a variation
        let variation: OptimizelyVariation = OptimizelyManager.optimizely!.activateExperimentForKey("Flickr_Pictures", withUserId: OptimizelyManager.getUserId());
        
        if (variation.variationKey == "Dogs") {
            print("Variation Dogs")
            flickrPhotoSearchText.text = "golden retriever"
        }
        else if (variation.variationKey == "Cats") {
            print("Variation Cats")
            flickrPhotoSearchText.text = "jumping cat"
        }
        
        FlickrKit.sharedFlickrKit().call(flickrPhotoSearchText) { (response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (response != nil) {
                    // pull out the photo urls from the results
                    let topPhotos = response["photos"] as! [NSObject: AnyObject]
                    let photoArray = topPhotos["photo"] as! [[NSObject: AnyObject]]
                    for photoDictionary in photoArray {
                        let photoURL = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeLarge1024, fromPhotoDictionary: photoDictionary)
                        AppDelegate.photoURLs.append(photoURL)
                    }
                    self.loadPhotos(AppDelegate.photoURLs)
                }
                else {
                    // Iterating over specific errors for each service
                    // TODO Josh W. Handle the error
                    switch error.code {
                    case FKFlickrInterestingnessGetListError.ServiceCurrentlyUnavailable.rawValue:
                        break;
                    default:
                        break;
                    }
                }
            })
        }
    }
    
    func loadPhotos(photoURLs: [NSURL]) {
        print("loadPhotos")
        for url in photoURLs {
            let urlRequest = NSURLRequest(URL: url)
            let urlResponse: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            let downloadedData: NSData
            do {
                downloadedData = try NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: urlResponse)
                let image = UIImage(data: downloadedData)
                AppDelegate.images.append(image!)
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        OptimizelyManager.resetUserId()
        exit(0)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        downloadImages()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

