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
    
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    var videoUrl: String?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        toId = dictionary["toId"] as? String
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        
        videoUrl = dictionary["videoUrl"] as? String
    }
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId: fromId
    }
}
