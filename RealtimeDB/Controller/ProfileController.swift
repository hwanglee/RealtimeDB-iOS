//
//  ProfileController.swift
//  RealtimeDB
//
//  Created by Hwang Lee on 12/10/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import UIKit
import Firebase

class ProfileController: UIViewController {
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var phoneLabel: UILabel!
    var db : DatabaseReference!
    var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Database.database().reference()
        
        setupNavbar()
        setupLabels()
    }
    
    func setupNavbar() {
        self.title = "Profile"
        editHidden(label: false, textField: true)
        
        let locationButton = UIButton(type: .roundedRect)
        locationButton.setTitle("Logout", for: .normal)
        locationButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: locationButton)
        self.navigationItem.leftBarButtonItem = barButton
        
        addEditButton()
    }
    
    @objc func edit() {
        editHidden(label: true, textField: false)
        
        self.view.endEditing(true)
        let editButton = UIButton(type: .roundedRect)
        editButton.setTitle("Done", for: .normal)
        editButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        let barButton2 = UIBarButtonItem(customView: editButton)
        self.navigationItem.rightBarButtonItem = barButton2
    }
    
    @objc func done() {
        editHidden(label: false, textField: true)
        
        let uid = Auth.auth().currentUser?.uid
        var data : [String : AnyObject] = [:]
        
        if let user = user {
            data = ["address": addressTextField.text, "cellPhone": phoneTextField.text, "createdAt": user.createdAt!, "email": user.email!,  "firstName": firstNameTextField.text, "id": user.id!, "lastName": lastNameTextField.text, "subscription": user.subscription!, "type": user.type!] as [String : AnyObject]
        }
        
        db.child("users").child(uid!).setValue(data) { (error, ref) in
            if error != nil {
                print("error")
            } else {
                self.addEditButton()
                self.view.endEditing(true)
            }
        }
        
    }
    
    func editHidden(label: Bool, textField: Bool) {
        firstNameLabel.isHidden = label
        lastNameLabel.isHidden = label
        addressLabel.isHidden = label
        phoneLabel.isHidden = label
        firstNameTextField.isHidden = textField
        lastNameTextField.isHidden = textField
        addressTextField.isHidden = textField
        phoneTextField.isHidden = textField
    }
    
    func addEditButton() {
        let editButton = UIButton(type: .roundedRect)
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)
        let barButton2 = UIBarButtonItem(customView: editButton)
        self.navigationItem.rightBarButtonItem = barButton2
    }
    
    @objc func logout() {
        try! Auth.auth().signOut()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginController")
        
        let navController = UINavigationController(rootViewController: vc!)
        self.present(navController, animated: true, completion: nil)
    }
    
    func setupLabels() {
        let uid = Auth.auth().currentUser?.uid
        db.child("users").child(uid!).observe(.value) { (snapshot) in
            self.user = User(snapshot: snapshot)
            
            if let user = self.user {
                self.firstNameLabel.text = user.firstName!
                self.firstNameTextField.text = user.firstName!
                self.lastNameLabel.text = user.lastName!
                self.lastNameTextField.text = user.lastName!
                self.addressLabel.text = user.address!
                self.addressTextField.text = user.address!
                self.phoneLabel.text = user.cellPhone!
                self.phoneTextField.text = user.cellPhone!
            }
        }
        
        
    }
}
