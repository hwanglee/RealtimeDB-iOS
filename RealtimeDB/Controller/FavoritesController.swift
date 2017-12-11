//
//  MainController.swift
//  RealtimeDB
//
//  Created by Hwang Lee on 12/4/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}


class FavoritesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var db : DatabaseReference?
    @IBOutlet var tableView: UITableView!
    var items = [Post]()
    var favorites = [Post]()
    var heightAtIndexPath = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Database.database().reference()
        self.favorites.removeAll()
        loadFavorites()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupNavbar()
    }
    
    func setupNavbar() {
        self.title = "Favorites"
    }
    
    func loadFavorites() {
        let userID = Auth.auth().currentUser?.uid
        var postIDs : [String] = []
        var newItems : [Post] = []
        
        
        db?.child("favorites").child(userID!).observe(.value) { (snapshot) in
            postIDs = []
            newItems = []
            
            for item in snapshot.children {
                let item = item as? DataSnapshot
                print(item!.key)
                postIDs.append(item!.key)
            }
            
            
            for id in postIDs {
                self.db?.child("posts").child(id).observe(.value) { (snapshot) in
                    let post = Post(snapshot: snapshot)
                    if let id = post.id {
                        let reference = Storage.storage().reference(forURL: "gs://realtime-1608c.appspot.com/posts/\(id)/0")
                        
                        reference.getData(maxSize: 1 * 1024 * 1024, completion: { (data, error) in
                            if let error = error {
                                print(error)
                            } else {
                                let image = UIImage(data: data!)
                                post.addImage(img: image)
                                self.tableView.reloadData()
                            }
                        })
                        
                        newItems.append(post)
                        print("\(newItems.count) ASDASDSD")
                        self.favorites = newItems
                        self.tableView.reloadData()
                    }
                }
            }
            
        }
        
        self.db?.child("favorites").child(userID!).observe(.childRemoved, with: { (removedData) in
            self.favorites.removeAll()
            self.tableView.reloadData()
            self.loadFavorites()
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favoriteInfo" {
            let controller = segue.destination as! PostInfoController
            let post = sender as! Post
            
            controller.post = post
        }
    }
    
    
    
    // MARK: TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(favorites.count) TABLE VIEW")
        return self.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomCell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        cell.titleLabel.text = self.favorites[indexPath.row].title
        cell.contentLabel.text = self.favorites[indexPath.row].summary
        cell.postImage.image = self.favorites[indexPath.row].image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = favorites[indexPath.row]
        
        self.performSegue(withIdentifier: "favoriteInfo", sender: post)
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
        let favoriteAction = UITableViewRowAction(style: .default, title: "Unfavorite") { (action, index) in
            let uid = Auth.auth().currentUser?.uid
            let usersRef = self.db?.child("favorites").child(uid!).child(self.favorites[indexPath.row].id!)
            usersRef?.removeValue()
            
            let alert = UIAlertController(title: "", message: "Favorite Removed", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            // change to desired number of seconds (in this case 5 seconds)
            let when = DispatchTime.now() + 0.7
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                alert.dismiss(animated: true, completion: nil)
            }
        }
        favoriteAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.7922, alpha: 1.0)
        
        return [favoriteAction]
    }
    
    
}



