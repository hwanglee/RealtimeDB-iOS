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
import Firebase


class PostInfoController: UIViewController {
    
    // MARK: outlets
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var publisherLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var openMapsButton: UIButton!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var publisherNameLabel: UILabel!
    @IBOutlet var publisherInfoLabel: UILabel!
    @IBOutlet var publisherEmailLabel: UILabel!
    
    var data = (Post(), User())
    var post : Post?
    var publisher : User?
    var location : CLLocationCoordinate2D?
    var db = Database.database()
    var storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        post = data.0
        publisher = data.1
        
        print(post!.id!)
        setupUI()
        
        setupMap()
        setupNavbar()
    }
    
    @objc func favorite() {
        let uid = Auth.auth().currentUser?.uid
        let usersRef = self.db.reference().child("favorites").child(uid!).child(post!.id!)
        usersRef.setValue(true)
        
        let alert = UIAlertController(title: "", message: "Favorite Added", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 0.7
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func setupUI() {
        titleLabel.text = post!.title
        contentLabel.text = post!.content
        postImage.image = post!.image
        publisherLabel.text = publisher!.firstName! + " " + publisher!.lastName!
        publisherNameLabel.text = publisher!.firstName! + " " + publisher!.lastName!
        publisherInfoLabel.text = post!.end
        publisherEmailLabel.text = publisher!.email!
        scrollView.contentSize = CGSize.init(width: 400, height: 1150)
    }
    
    func setupNavbar() {
        let locationButton = UIButton(type: .roundedRect)
        locationButton.setTitle("Favorite", for: .normal)
        locationButton.addTarget(self, action: #selector(favorite), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: locationButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func setupMap() {
        mapView.mapType = MKMapType.standard
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(post!.location!) { (placemarks, error) in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            
            self.location = CLLocationCoordinate2DMake(lat!, lon!)
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(self.location!, span)
            self.mapView.setRegion(region, animated: false)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.location!
            annotation.title = self.post!.location
            self.mapView.addAnnotation(annotation)
        }
    }

    
    // MARK: Button functions
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
        if let url = URL(string: "tel://" + (publisher?.cellPhone)!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
