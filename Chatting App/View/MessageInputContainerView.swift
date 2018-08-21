//
//  MessageInputContainerView.swift
//  Chatting App
//
//  Created by Raju on 8/21/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit

class MessageInputContainerView: UIView {
    
    var messageLogController: MessageLogController? {
        didSet {
            uploadMediaButton.addTarget(messageLogController, action: #selector(MessageLogController.uploadMediaButtonAction), for: .touchUpInside)
            sendButton.addTarget(messageLogController, action: #selector(MessageLogController.sendButtonAction), for: .touchUpInside)
            messageTextField.delegate = messageLogController
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareView() {
        
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        //UIButton "Send Image"
        addSubview(uploadMediaButton)
        uploadMediaButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        uploadMediaButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadMediaButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        uploadMediaButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        //UIButton "Send"
        sendButton.isEnabled = false
        addSubview(sendButton)
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        //UITextField "Message Input"
        addSubview(messageTextField)
        messageTextField.leftAnchor.constraint(equalTo: uploadMediaButton.rightAnchor, constant: 8).isActive = true
        messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        messageTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        messageTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        //UIView "Separator"
        let separatorView = UIView()
        separatorView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        
        separatorView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    let uploadMediaButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "uploadimage"), for: .normal)
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let messageTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.placeholder = "Type your messages..."
        textField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
}
