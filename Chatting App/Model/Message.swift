//
//  Message.swift
//  Chatting App
//
//  Created by Raju on 8/13/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {

    var toId: String?
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        toId = dictionary["toId"] as? String
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
    }
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId: fromId
    }
}
