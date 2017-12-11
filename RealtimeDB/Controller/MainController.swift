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

class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var db : DatabaseReference?
    @IBOutlet weak var tableView: UITableView!
    var items = [Post]()
    var favorites = [Post]()
    var heightAtIndexPath = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Database.database().reference()
        loadPosts()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupNavbar()
        
    }
    
    func setupNavbar() {
        self.title = "Posts"
        
        let locationButton = UIButton(type: .roundedRect)
        locationButton.setTitle("Location", for: .normal)
        locationButton.addTarget(self, action: #selector(random), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: locationButton)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    
    func loadPosts() {
        db?.child("posts").observe(.value) { (snapshot) in
            var newItems = [Post]()
            
            // loop through the children and append them to the new array
            for item in snapshot.children {
                let post = Post(snapshot: item as! DataSnapshot)
                let reference = Storage.storage().reference(forURL: "gs://realtime-1608c.appspot.com/posts/\(post.id!)/0")
                
                reference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                    if let error = error {
                        //                        print(error)
                    } else {
                        
                        DispatchQueue.main.async { //UPDATED PART OF CODE STARTS HERE
                            let image = UIImage(data: data!)
                            post.addImage(img: image)
                            self.tableView.reloadData()
                        }
                        
                    }
                }
                
                newItems.append(post)
            }
            
            // replace the old array
            self.items = newItems.reversed()
            // reload the UITableView
            self.tableView.reloadData()
        }
        
    }
    
    @objc func random() {
        print("hI")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postInfo" {
            let controller = segue.destination as! PostInfoController
            let post = sender as! Post
            
            controller.post = post
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
        
        self.performSegue(withIdentifier: "postInfo", sender: post)
        tableView.deselectRow(at: indexPath, animated: true)
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


