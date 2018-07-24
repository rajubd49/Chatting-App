//
//  LoginController.swift
//  Chatting App
//
//  Created by Raju on 7/23/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signButton: UIButton!
    
    private var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ref = Database.database().reference(fromURL: "https://chatting-app-a2f94.firebaseio.com/")
        ref.updateChildValues(["somevalue": 123456])
        
    }
    
    @IBAction func segmentValueChange(_ sender: Any) {
    }
    
    @IBAction func signButtonAction(_ sender: Any) {
    }
    
}

