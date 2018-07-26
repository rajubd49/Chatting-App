//
//  User.swift
//  Chatting App
//
//  Created by Raju on 7/26/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var email: String?

    init(dictionary: [String: AnyObject]) {
        super.init()
        name = dictionary["name"] as? String
        email = dictionary["email"] as? String
    }
}
