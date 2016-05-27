//
//  FirstViewController.swift
//  tvOS-Flickr-App
//
//  Created by Joshua H. Wang on 5/11/16.
//  Copyright © 2016 wangjoshuah. All rights reserved.
//

import UIKit

class FirstViewController: UICollectionViewController {
    
    var photoURLs: [NSURL]!
    var images: [UIImage]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoURLs = []
        self.images = []
        // Do any additional setup after loading the view, typically from a nib.
        let flickrInteresting = FKFlickrInterestingnessGetList()
        flickrInteresting.per_page = "15"
        
        FlickrKit.sharedFlickrKit().call(flickrInteresting) { (response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (response != nil) {
                    // pull out the photo urls from the results
                    let topPhotos = response["photos"] as! [NSObject: AnyObject]
                    let photoArray = topPhotos["photo"] as! [[NSObject: AnyObject]]
                    for photoDictionary in photoArray {
                        let photoURL = FlickrKit.sharedFlickrKit().photoURLForSize(FKPhotoSizeLarge1024, fromPhotoDictionary: photoDictionary)
                        self.photoURLs.append(photoURL)
                    }
                    self.loadPhotos(self.photoURLs)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FirstViewControllerCollectionViewCellReuiseIdentifier", forIndexPath: indexPath) 
        cell.backgroundColor = UIColor.blueColor()
        let imageView: UIImageView = UIImageView.init(image: self.images[indexPath.row])
        cell.contentView.addSubview(imageView)
        return cell
    }
    
    func loadPhotos(photoURLs: [NSURL]) {
        for url in photoURLs {
            let urlRequest = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                let image = UIImage(data: data!)
                self.images.append(image!)
                self.collectionView?.reloadData()
            })
        }
    }

}

