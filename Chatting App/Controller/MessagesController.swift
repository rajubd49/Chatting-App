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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.tableView.reloadData()
            })
        }
    }
    var messageDictionary = [String:Message]()
    lazy var signout: UIBarButtonItem = {
        UIBarButtonItem.init(image: #imageLiteral(resourceName: "logout"), style: .plain, target: self, action: #selector(self.signoutAction))
    }()
    
    lazy var newMessage: UIBarButtonItem = {
        UIBarButtonItem.init(image: #imageLiteral(resourceName: "newmessage"), style: .plain, target: self, action: #selector(self.newMessageAction))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = signout
        navigationItem.rightBarButtonItem = newMessage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chekedLoginStatusWithFetchUser()
        observeUserMessages()
    }
    
    fileprivate func chekedLoginStatusWithFetchUser() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(signoutAction), with: self, afterDelay: 0)
        } else {
            if let uid = Auth.auth().currentUser?.uid {
                Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in
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
    
    fileprivate func observeUserMessages() {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let databaseReference = Database.database().reference().child("user_messages").child(uid)
        databaseReference.observe(.childAdded, with: { (dataSnapshot) in
            let userId = dataSnapshot.key
            Database.database().reference().child("user_messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessagesWithMessageId(messageId: messageId)
            }, withCancel: nil)
        }, withCancel: nil)
        
        databaseReference.observe(.childRemoved, with: { (snapshot) in
            self.messageDictionary.removeValue(forKey: snapshot.key)
            self.reloadSortedMessages()
        }, withCancel: nil)
    }
    
    fileprivate func fetchMessagesWithMessageId(messageId: String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                if let chatPartnerId = message.chatPartnerId() {
                    self.messageDictionary[chatPartnerId] = message
                    self.reloadSortedMessages()
                }
            }
        }, withCancel: nil)
    }
    
    private func reloadSortedMessages() {
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
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
    
    // MARK: - Table view datasource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let message = self.messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let uid = Auth.auth().currentUser?.uid {
                let message = messages[indexPath.row]
                if let chatPartnerId = message.chatPartnerId() {
                    Database.database().reference().child("user_messages").child(uid).child(chatPartnerId).removeValue { (error, reference) in
                        if error != nil {print(error?.localizedDescription ?? ""); return}
                        self.messageDictionary.removeValue(forKey: chatPartnerId)
                        self.reloadSortedMessages()
                    }
                }
            }
        }
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let message = messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerId() {
        Database.database().reference().child("users").child(chatPartnerId).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    user.id = chatPartnerId
                    self.showMessageLogControllerWithUser(user: user)
                }
            }, withCancel: nil)
        }
    }

}
