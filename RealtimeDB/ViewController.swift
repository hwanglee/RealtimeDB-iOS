//
//  ViewController.swift
//  RealtimeDB
//
//  Created by Hwang Lee on 12/4/17.
//  Copyright © 2017 Hwang Lee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class LoginController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.placeholder = "Email"
        passwordField.placeholder = "Pasword"
    }

    @IBAction func loginAction(_ sender: UIButton) {
        if self.usernameField.text == "" || self.passwordField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter all fields", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        else {
            Auth.auth().signIn(withEmail: usernameField.text!, password: passwordField.text!, completion: { (user, error) in
                if error == nil {
                    print("Logged in")
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainController")
//                    self.navigationController!.pushViewController(vc!, animated: true)
                    
                    let navController = UINavigationController(rootViewController: vc!)
                    self.present(navController, animated: true, completion: nil)
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
    

    @IBAction func registerAction(_ sender: UIButton) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegisterController")
//        self.present(vc!, animated: true, completion: nil)
        
        self.performSegue(withIdentifier: "registerSegue", sender: nil)
        
    }
}

