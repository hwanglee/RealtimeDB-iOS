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
    var title: String?
    var content: String?
    var id: String?
    var category: Int?
    var pid: String?
    var start: String?
    var end: String?
    var summary: String?
    var location: String?
    var image: UIImage?
    var ref: DatabaseReference?
    
    init(snapshot: DataSnapshot) {
        super.init()
        if let values = snapshot.value as? [String:AnyObject] {
            
            title = values["title"] as? String
            content = values["content"] as? String
            extractContent(content: content)
            id = values["id"] as? String
            category = values["category"] as? Int
            pid = values["pid"] as? String
            start = values["start"] as? String
            end = values["end"] as? String
            summary = values["summary"] as? String
            location = values["location"] as? String
            ref = snapshot.ref
        }
    }
    
    func addImage(img: UIImage?) {
        image = img
    }
    
    func extractContent(content: String?) {
        if let text = content {
            let regex = try! NSRegularExpression(pattern:">(.*?)<", options: [])
            let temp = text as NSString
            var results = [String]()
            
            regex.enumerateMatches(in: text, options: [], range: NSMakeRange(0, text.count)) { (result, flag, stop) in
                if let range = result?.range(at: 1) {
                    results.append(temp.substring(with: range))
                }
            }
            
            print(results)
        }
    }
}
