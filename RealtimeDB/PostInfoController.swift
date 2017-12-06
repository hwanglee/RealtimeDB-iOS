//
//  PostInfoController.swift
//  RealtimeDB
//
//  Created by Hwang Lee on 12/5/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseStorage

class PostInfoController: UIViewController {
    
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var publisherLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var openMapsButton: UIButton!
    @IBOutlet var callButton: UIButton!
    
    var post : Post?

    var location : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(post!.id)
        titleLabel.text = post!.title
        contentLabel.text = post!.content
        
        mapView.mapType = MKMapType.standard
        
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(post!.location) { (placemarks, error) in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            
            self.location = CLLocationCoordinate2DMake(lat!, lon!)
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(self.location!, span)
            self.mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.location!
            annotation.title = self.post!.location
            self.mapView.addAnnotation(annotation)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openMapsPress(_ sender: UIButton) {
        let regionDistance : CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegionMakeWithDistance(self.location!, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: self.location!, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = post?.location
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func callPress(_ sender: UIButton) {
    }
}
