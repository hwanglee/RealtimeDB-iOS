//
//  User.swift
//  RealtimeDB
//
//  Created by Hwang Lee on 12/11/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import Foundation
import Firebase

class User : NSObject {
    var address: String?
    var cellPhone: String?
    var createdAt: Int?
    var email: String?
    var firstName: String?
    var id: String?
    var lastName: String?
    var subscription: Bool?
    var type: String?
    var db = Database.database().reference()
    
    init(snapshot: DataSnapshot) {
        let values = snapshot.value as! [String: AnyObject]
        self.address = values["address"] as? String
        self.cellPhone = values["cellPhone"] as? String
        self.createdAt = values["createdAt"] as? Int
        self.email = values["email"] as? String
        self.firstName = values["firstName"] as? String
        self.id = values["id"] as? String
        self.lastName = values["lastName"] as? String
        self.subscription = values["subscription"] as? Bool
        self.type = values["type"] as? String
    }
    
    override init() {
        self.address = ""
        self.cellPhone = ""
        self.createdAt = 0
        self.email = ""
        self.firstName = ""
        self.id = ""
        self.lastName = ""
        self.subscription = false
        self.type = ""
        
    }

}
