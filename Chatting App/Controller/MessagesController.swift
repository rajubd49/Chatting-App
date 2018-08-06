//
//  MessagesController.swift
//  Chatting App
//
//  Created by Raju on 7/24/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navImageView: UIImageView!
    @IBOutlet weak var navTitleLabel: UILabel!
    
    var users = [User] () {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    lazy var signout: UIBarButtonItem = {
        UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(self.signoutAction))
    }()
    
    lazy var newMessage: UIBarButtonItem = {
        UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(self.newMessageAction))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = signout
        navigationItem.rightBarButtonItem = newMessage
        navView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.navViewAction)))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chekedLoginStatusWithFetchUser()
    }
    
    fileprivate func chekedLoginStatusWithFetchUser() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(signoutAction), with: self, afterDelay: 0)
        } else {
            if let uid = Auth.auth().currentUser?.uid {
                Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                    print(dataSnapshot)
                    if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                        let user = User(dictionary: dictionary)
                        self.navTitleLabel.text = user.name
                        if let imageUrl = user.imageurl {
                            self.navImageView.loadImage(urlString: imageUrl)
                        }
                    }
                }, withCancel: nil)
            }
        }
        
    }

    @objc private func signoutAction() {
        
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        
        if let loginController =  storyboard?.instantiateViewController(withIdentifier: "LoginController") {
            present(loginController, animated: true, completion: nil)
        }
    }
    
    @objc private func newMessageAction() {
        if let newMessageNavController =  storyboard?.instantiateViewController(withIdentifier: "NewMessageNavController") {
            present(newMessageNavController, animated: true, completion: nil)
        }
    }
    
    @IBAction func navViewAction(_ sender: Any) {
        performSegue(withIdentifier: "MessageLogSegueID", sender: self)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let user = self.users[indexPath.row]
        cell.nameLabel?.text = user.name
        cell.emailLabel?.text = user.email
        cell.profileImageView?.loadImage(urlString: user.imageurl ?? "")
        return cell
    }

}
