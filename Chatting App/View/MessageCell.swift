//
//  MessageCell.swift
//  Chatting App
//
//  Created by Raju on 8/15/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    
    static let lightBlueColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    static let lightGrayColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
    
    var messageLogController: MessageLogController?
    var message: Message?
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let messageBubbleView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "chat")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        // Gesture recognizer won't work unless you put lazy var insted of let :)
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedMessageImage)))
        return imageView
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "playbutton"), for: .normal)
        button.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.addTarget(self, action: #selector(tappedPlayButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func tappedMessageImage(tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil {
            return
        }
        if let imageView =  tapGesture.view as? UIImageView {
            messageLogController?.messageImageViewDidTap(tappedImageView: imageView)
        }
    }
    
    @objc func tappedPlayButton() {
        if let message = message {
            messageLogController?.messageVideoViewDidTap(message: message, bubbleView: messageBubbleView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLogController?.removePlayerLayer()
    }
    
    var messageBubbleWidthAnchor: NSLayoutConstraint?
    var messageBubbleLeftAnchor: NSLayoutConstraint?
    var messageBubbleRightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(messageBubbleView)
        addSubview(messageTextView)
        messageBubbleView.addSubview(messageImageView)
        messageBubbleView.addSubview(playButton)
        
        //ImageView Constrain
        messageImageView.leftAnchor.constraint(equalTo: messageBubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: messageBubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: messageBubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: messageBubbleView.heightAnchor).isActive = true
        
        //Button Constrain
        playButton.centerXAnchor.constraint(equalTo: messageBubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: messageBubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 80.0).isActive = true

        //ImageView Constrain
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 2).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        
        //BubbleView Constraint
        messageBubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageBubbleLeftAnchor = messageBubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        messageBubbleLeftAnchor?.isActive = true
        messageBubbleRightAnchor = messageBubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        messageBubbleRightAnchor?.isActive = true
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
