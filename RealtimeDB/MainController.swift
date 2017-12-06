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

class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let animals = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    var db : DatabaseReference?
    @IBOutlet weak var tableView: UITableView!
    var items = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Database.database().reference()
        loadPosts()
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomCell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        cell.titleLabel.text = self.items[indexPath.row].title
        cell.contentLabel.text = self.items[indexPath.row].summary
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postInfo" {
            let controller = segue.destination as! PostInfoController
            let post = sender as! Post
            
            controller.post = post
        }
    }

}
