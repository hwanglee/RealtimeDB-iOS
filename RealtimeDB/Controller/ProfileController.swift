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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        // Do any additional setup after loading the view.
    }

    func setupNavbar() {
        self.title = "Profile"
        
        let locationButton = UIButton(type: .roundedRect)
        locationButton.setTitle("Logout", for: .normal)
        locationButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: locationButton)
        self.navigationItem.leftBarButtonItem = barButton
    }

    @objc func logout() {
        try! Auth.auth().signOut()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginController")
        //                    self.navigationController!.pushViewController(vc!, animated: true)
        
        let navController = UINavigationController(rootViewController: vc!)
        self.present(navController, animated: true, completion: nil)
    }
}
