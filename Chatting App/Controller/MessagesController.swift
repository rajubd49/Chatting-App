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
    
    var messages = [Message] () {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var messageDictionary = [String:Message]()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chekedLoginStatusWithFetchUser()
        observeMessages()
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
    
    fileprivate func observeMessages() {
        self.messages.removeAll()
        let databaseReference = Database.database().reference().child("messages")
        databaseReference.observe(.childAdded, with: { (dataSnapshot) in
            if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
//                self.messages.append(message)
                if let toId = message.toId {
                    self.messageDictionary[toId] = message
                    self.messages = Array(self.messageDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                    })
                }
            }
        }, withCancel: nil)
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
            if let newMessageController = newMessageNavController.childViewControllers.first as? NewMessageController {
                newMessageController.messagesController = self
            }
            present(newMessageNavController, animated: true, completion: nil)
        }
    }
    
    func showMessageLogControllerWithUser(user:User) {
        if let messageLogController = storyboard?.instantiateViewController(withIdentifier:"MessageLogController") as? MessageLogController {
            messageLogController.user = user
            navigationController?.pushViewController(messageLogController, animated: true)
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let message = self.messages[indexPath.row]
        cell.message = message
        return cell
    }

}
