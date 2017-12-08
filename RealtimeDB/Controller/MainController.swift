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


class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let animals = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    var db : DatabaseReference?
    @IBOutlet weak var tableView: UITableView!
    var items = [Post]()
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
                let reference = Storage.storage().reference(forURL: "gs://realtime-1608c.appspot.com/posts/\(post.id)/0")
                
                reference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                    if let error = error {
                        
                        print(error)
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
            self.items = newItems
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
    
    
    

}


