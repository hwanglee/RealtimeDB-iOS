//
//  MainController.swift
//  RealtimeDB
//
//  Created by Hwang Lee on 12/4/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var db : DatabaseReference?
    var currentCity = ""
    @IBOutlet weak var tableView: UITableView!
    var items = [Post]()
    var favorites = [Post]()
    var heightAtIndexPath = NSMutableDictionary()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocation()
        db = Database.database().reference()
        loadPosts()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupNavbar()
    }
    
    func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }
    
    func setupNavbar() {
        lookUpCurrentLocation { (placemark) in
            if placemark != nil {
                self.title = placemark?.locality
                self.currentCity = (placemark?.locality)!
            }
        }
        
        let locationButton = UIButton(type: .roundedRect)
        locationButton.setTitle("Location", for: .normal)
        locationButton.addTarget(self, action: #selector(random), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: locationButton)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func lookUpLocation(posts: [Post], completion: @escaping() -> ()) {
        guard let post = posts.first else {
            completion()
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(post.location!) { (placemarks, error) in
            
            if let placemark = placemarks?.first {
                if placemark.locality != self.currentCity {
                    print("a")
                }
            }
        
            let remainingPosts = Array(posts[1..<posts.count])
            self.lookUpLocation(posts: remainingPosts, completion: completion)
        }
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                    // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
    
    func loadPosts() {
        db?.child("posts").observe(.value) { (snapshot) in
            var newItems = [Post]()
            let currentDate = Date()
            let geocoder = CLGeocoder()
            
            // loop through the children and append them to the new array
            for item in snapshot.children {
                let post = Post(snapshot: item as! DataSnapshot)
                let reference = Storage.storage().reference(forURL: "gs://realtime-1608c.appspot.com/posts/\(post.id!)/0")
                
                reference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                    if error != nil {
                        //                        print(error)
                    } else {
                        DispatchQueue.main.async {
                            let image = UIImage(data: data!)
                            post.addImage(img: image)
                            self.tableView.reloadData()
                        }
                        
                    }
                    
                }
                
                if let endDate = post.endDate {
                    if endDate > currentDate {
                        newItems.append(post)
                    }
                }
            }
            
            // replace the old array
            self.items = newItems.reversed()
            self.lookUpLocation(posts: self.items) { () in
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    @objc func random() {
        print("hI")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postInfo" {
            let controller = segue.destination as! PostInfoController
            let data = sender as! (Post, User)
            
            controller.data = data
        }
    }
    
    
    
    // MARK: TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomCell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        cell.titleLabel.text = self.items[indexPath.row].title
        cell.contentLabel.text = self.items[indexPath.row].summary
        cell.postImage.image = self.items[indexPath.row].image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = items[indexPath.row]
        let uid = post.pid!
        
        db?.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let publisher = User(snapshot: snapshot)
            
            self.performSegue(withIdentifier: "postInfo", sender: (post, publisher))
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favoriteAction = UITableViewRowAction(style: .default, title: "Favorite") { (action, index) in
            let uid = Auth.auth().currentUser?.uid
            let usersRef = self.db?.child("favorites").child(uid!).child(self.items[indexPath.row].id!)
            usersRef?.setValue(true)
            
            let alert = UIAlertController(title: "", message: "Favorite Added", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            // change to desired number of seconds (in this case 5 seconds)
            let when = DispatchTime.now() + 0.7
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                alert.dismiss(animated: true, completion: nil)
            }
        }
        favoriteAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0)
        
        return [favoriteAction]
    }
}


