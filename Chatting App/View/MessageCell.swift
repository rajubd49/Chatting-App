//
//  MessageCell.swift
//  Chatting App
//
//  Created by Raju on 8/15/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Dummy text"
        textView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let messageBubbleView: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var messageBubbleWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(messageBubbleView)
        addSubview(messageTextView)
        
        //BubbleView Constraint
        messageBubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageBubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        messageBubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        messageBubbleWidthAnchor = messageBubbleView.widthAnchor.constraint(equalToConstant: 200.0)
        messageBubbleWidthAnchor?.isActive = true
        
        //TextView Constraint
        messageTextView.leftAnchor.constraint(equalTo: messageBubbleView.leftAnchor, constant: 8).isActive = true
        messageTextView.rightAnchor.constraint(equalTo: messageBubbleView.rightAnchor).isActive = true
        messageTextView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        messageTextView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
