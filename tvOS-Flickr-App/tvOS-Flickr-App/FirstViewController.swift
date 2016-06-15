//
//  FirstViewController.swift
//  tvOS-Flickr-App
//
//  Created by Joshua H. Wang on 5/11/16.
//  Copyright © 2016 wangjoshuah. All rights reserved.
//

import UIKit
import FlickrKit

class FirstViewController: UICollectionViewController {
    
    var photoURLs: [NSURL]!
    var images: [UIImage]!
    
    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        NSLog("viewDidAppear")
        self.collectionView!.reloadData()
    }
    
    override func viewDidLoad() {
        NSLog("viewDidLoad");
        super.viewDidLoad()
        self.photoURLs = []
        self.images = []
        // Do any additional setup after loading the view, typically from a nib.
        let flickrInteresting = FKFlickrInterestingnessGetList()
        flickrInteresting.per_page = "1"
        
        let flickrPhotoSearchText = FKFlickrPhotosSearch()
        flickrPhotoSearchText.text = "cat dog"
        flickrPhotoSearchText.per_page = "1"
        flickrPhotoSearchText.safe_search = "1"
        flickrPhotoSearchText.content_type = "1"
        flickrPhotoSearchText.sort = "interestingness-desc";
        
        let variation: OptimizelyVariation = OptimizelyManager.optimizely!.activateExperimentForKey("Flickr_Pictures", withUserId: OptimizelyManager.userId!);
        print(variation.variationKey);
        if (variation.variationKey == "Dogs") {
            flickrPhotoSearchText.text = "Dogs"
        }
        else if (variation.variationKey == "Cats") {
            flickrPhotoSearchText.text = "Cats"
        }
        
        FlickrKit.sharedFlickrKit().call(flickrPhotoSearchText) { (response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (response != nil) {
                    // pull out the photo urls from the results
                    let topPhotos = response["photos"] as! [NSObject: AnyObject]
                    let photoArray = topPhotos["photo"] as! [[NSObject: AnyObject]]
                    for photoDictionary in photoArray {
                        let photoURL = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeLarge2048, fromPhotoDictionary: photoDictionary)
                        self.photoURLs.append(photoURL)
                    }
                    //                    self.loadPhotos(self.photoURLs)
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
                self.collectionView?.reloadData()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoURLs.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FirstViewControllerCollectionViewCellReuiseIdentifier", forIndexPath: indexPath)
        let imageView: UIImageView = UIImageView.init(image: AppDelegate.images[indexPath.row])
        //        imageView.image = AppDelegate.images[indexPath.row]
        cell.contentView.addSubview(imageView)
        print(indexPath.description)
        print(indexPath.row.description)
        return cell
    }
    
    func downloadImageFromURL(url: NSURL) -> UIImage {
        print("downloadImageFromURL")
        let urlRequest = NSURLRequest(URL: url)
        let urlResponse: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        let downloadedData: NSData
        var image: UIImage = UIImage.init()
        do {
            downloadedData = try NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: urlResponse)
            image = UIImage(data: downloadedData)!
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        return image
    }
    
    func loadPhotos(photoURLs: [NSURL]) {
        print("loadPhotos")
        for url in photoURLs {
            let urlRequest = NSURLRequest(URL: url)
            //            let urlResponse: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            //            let downloadedData: NSData
            //            do {
            //                downloadedData = try NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: urlResponse)
            //                let image = UIImage(data: downloadedData)
            //                self.images.append(image!)
            //            }
            //            catch let error as NSError {
            //                print(error.localizedDescription)
            //            }
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                let image = UIImage(data: data!)
                self.images.append(image!)
                self.collectionView?.reloadData()
            })
            self.collectionView!.reloadData()
        }
    }
    
}

