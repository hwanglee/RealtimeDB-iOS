//
//  Post.swift
//  RealtimeDB
//
//  Created by Hwang Lee on 12/5/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import Firebase
import FirebaseDatabase
import Foundation

class Post : NSObject {
    var title: String
    var content: String
    var id: String
    var category: Int
    var pid: String
    var start: String
    var end: String
    var summary: String
    var location: String
    
    init(snapshot: DataSnapshot) {
        let values = snapshot.value as? [String:AnyObject]
        
        title = values!["title"] as! String
        content = values!["content"] as! String
        id = values!["id"] as! String
        category = values!["category"] as! Int
        pid = values!["pid"] as! String
        start = values!["start"] as! String
        end = values!["end"] as! String
        summary = values!["summary"] as! String
        location = values!["location"] as! String
    }
}
