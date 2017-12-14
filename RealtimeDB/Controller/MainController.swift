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
    var posts = [Post]()
    var filteredPosts = [Post]()
    var heightAtIndexPath = NSMutableDictionary()
    let locationManager = CLLocationManager()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        setupSearchBar()
        setupLocation()
        db = Database.database().reference()
        loadPosts()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: Setup stuff
    func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }
    
    func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Posts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
    
    // MARK: Searchbar stuff
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredPosts = posts.filter({(post: Post) -> Bool in
            return (post.title?.lowercased().contains(searchText.lowercased()))! || (post.location?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
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
            var newPosts = [Post]()
            let currentDate = Date()
            
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
                        newPosts.append(post)
                    }
                }
            }
            
            // replace the old array
            self.posts = newPosts.reversed()
            self.lookUpLocation(posts: self.posts) { () in
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
        if isFiltering() {
            return self.filteredPosts.count
        }
        
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomCell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        if isFiltering() {
            cell.titleLabel.text = self.filteredPosts[indexPath.row].title
            cell.contentLabel.text = self.filteredPosts[indexPath.row].summary
            cell.postImage.image = self.filteredPosts[indexPath.row].image
        } else {
            cell.titleLabel.text = self.posts[indexPath.row].title
            cell.contentLabel.text = self.posts[indexPath.row].summary
            cell.postImage.image = self.posts[indexPath.row].image
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
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
            let usersRef = self.db?.child("favorites").child(uid!).child(self.posts[indexPath.row].id!)
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

extension MainController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}



