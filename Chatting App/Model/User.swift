//
//  User.swift
//  Chatting App
//
//  Created by Raju on 7/26/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit

class User: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var imageurl: String?

    init(dictionary: [String: AnyObject]) {
        super.init()
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        email = dictionary["email"] as? String
        imageurl = dictionary["imageurl"] as? String
    }
}
