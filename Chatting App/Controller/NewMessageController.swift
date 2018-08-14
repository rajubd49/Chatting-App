//
//  NewMessageController.swift
//  Chatting App
//
//  Created by Raju on 7/24/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    var messagesController: MessagesController?
    var users = [User] () {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    lazy var cancel: UIBarButtonItem = {
        UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = cancel
        fetchAllusers()
    }

    @objc private func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    private func fetchAllusers() {
        Database.database().reference().child("users").observe(.childAdded, with: { (dataSnapshot) in
            print(dataSnapshot)
            if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = dataSnapshot.key
                if user.id !=  Auth.auth().currentUser?.uid {
                    self.users.append(user)
                }
            }
        }, withCancel: nil)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showMessageLogControllerWithUser(user: user)
        }
    }

}
