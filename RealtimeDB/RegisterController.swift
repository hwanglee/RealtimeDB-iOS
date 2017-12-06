//
//  RegisterController.swift
//  RealtimeDB
//
//  Created by Hwang Lee on 12/4/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class RegisterController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    var db : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameField.placeholder = "First name"
        lastNameField.placeholder = "Last name"
        addressField.placeholder = "Address"
        emailField.placeholder = "Email"
        passwordField.placeholder = "Password"
        phoneField.placeholder = "Phone number"
        db = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func registerAction(_ sender: UIButton) {
        if firstNameField.text! == "" || lastNameField.text! == "" || addressField.text! == "" || emailField.text! == "" || passwordField.text! == "" || phoneField.text! == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter all fields", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
            
        else {
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if error == nil {
                    let usersRef = self.db.child("users")
                    let uid = Auth.auth().currentUser?.uid
                    
                    let values = ["address": self.addressField.text!, "cellPhone": self.phoneField.text!, "createdAt": ServerValue.timestamp(), "email": self.emailField.text!,
                        "firstName": self.firstNameField.text!, "id": uid!, "lastName": self.lastNameField.text!, "subscription": false, "type": "reader"] as [String : Any]
                    
                    let result = usersRef.child(uid!).setValue(values)
                    
                    print("added")
                    
                    self.navigationController?.popToRootViewController(animated: true) 
                }
                
                else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)

                }
            })
        }
    }
    
    

}
