//
//  MessageLogController.swift
//  Chatting App
//
//  Created by Raju on 8/6/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit
import Firebase

class MessageLogController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextField.delegate = self
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: messageTextField.frame.height))
        messageTextField.leftView = paddingView
        messageTextField.leftViewMode = .always
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendAction(_ sender: Any) {
        let databaseReference = Database.database().reference().child("messages")
        let childReference = databaseReference.childByAutoId()
        let values = ["text": messageTextField.text!]
        childReference.updateChildValues(values)
        messageTextField.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendAction(UIButton.self)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let maxLength = text.utf16.count + string.utf16.count - range.length
        sendButton.isEnabled = maxLength > 0
        return true
    }
}
