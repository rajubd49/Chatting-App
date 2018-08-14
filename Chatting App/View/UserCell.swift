//
//  UserCell.swift
//  Chatting App
//
//  Created by Raju on 7/27/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {

    var message: Message? {
        didSet {
            let chatPartnerId: String?
            if message?.fromId == Auth.auth().currentUser?.uid {
                chatPartnerId = message?.toId
            } else {
                chatPartnerId = message?.fromId
            }
            if let id = chatPartnerId {
                let databaseReference = Database.database().reference().child("users").child(id)
                databaseReference.observeSingleEvent(of: .value, with: { (dataSnapshot) in
                    if let dictionary = dataSnapshot.value as? [String: AnyObject] {
                        self.nameLabel?.text = dictionary["name"] as? String
                        if let imageUrl = dictionary["imageurl"] as? String {
                            self.profileImageView?.loadImage(urlString: imageUrl)
                        }
                    }
                }, withCancel: nil)
            }
            emailLabel?.text = message?.text
            if let timestamp = message?.timestamp?.doubleValue {
                let date = Date(timeIntervalSince1970:timestamp)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC+6")
                timestampLabel?.text = dateFormatter.string(from: date)
            }
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
