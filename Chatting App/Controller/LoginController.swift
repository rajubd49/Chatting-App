//
//  LoginController.swift
//  Chatting App
//
//  Created by Raju on 7/23/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class LoginController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViewContentForSelectedSegment()
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageViewAction)))
    }
    
    private func updateViewContentForSelectedSegment() {
        nameTextField.isHidden = segmentControl.selectedSegmentIndex == 0
        let title = segmentControl.titleForSegment(at: segmentControl.selectedSegmentIndex)
        signButton.setTitle(title, for: .normal)
    }
    
    @IBAction func segmentValueChange(_ sender: Any) {
        updateViewContentForSelectedSegment()
    }
    
    @IBAction func signButtonAction(_ sender: Any) {
        segmentControl.selectedSegmentIndex == 0 ?  signinUser() : signupUser()
    }
    
    private func signinUser() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return print("Please fill up all the fields") }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            
            if error != nil { print(error!); return }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func signupUser() {
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else { return print("Please fill up all the fields") }
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            if error != nil { print(error!); return }
            guard let uid = authResult?.user.uid else { print("uid not found"); return }
            let imageName = UUID().uuidString
            let storageReference = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            if let imageData = UIImagePNGRepresentation(self.imageView.image!) {
                storageReference.putData(imageData, metadata: nil, completion: { (storageMetadata, error) in
                    if error != nil { print(error!); return }
                    storageReference.downloadURL(completion: { (url, error) in
                        if error != nil { print(error!); return }
                        if let imageUrlString = url?.absoluteString {
                            let databaseReference = Database.database().reference(fromURL: "https://chatting-app-a2f94.firebaseio.com/")
                            let usersReference = databaseReference.child("users").child(uid)
                            let values = ["name": name, "email": email, "imageurl": imageUrlString]
                            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                                if err != nil { print(err!); return }
                                self.segmentControl.selectedSegmentIndex = 0
                                self.updateViewContentForSelectedSegment()
                            })
                        }
                    })
                })
            }
        }
    }

}

