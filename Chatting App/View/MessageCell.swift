//
//  MessageCell.swift
//  Chatting App
//
//  Created by Raju on 8/15/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let messageTextView = UITextView()
        messageTextView.text = "Dummy text"
        messageTextView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        messageTextView.textAlignment = .right
        messageTextView.font = UIFont.systemFont(ofSize: 15)
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        return messageTextView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        
        //Constraint
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200.0).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
