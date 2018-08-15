//
//  MessageLogController.swift
//  Chatting App
//
//  Created by Raju on 8/6/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit
import Firebase

class MessageLogController: UIViewController,UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var user:User? {
        didSet {
            navigationItem.title = user?.name
            observeUserMessages()
        }
    }
    
    var messages = [Message] () {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextField.delegate = self
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: messageTextField.frame.height))
        messageTextField.leftView = paddingView
        messageTextField.leftViewMode = .always
        
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: "MessageCell")
        collectionView.alwaysBounceVertical = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func sendAction(_ sender: Any) {
        let databaseReference = Database.database().reference().child("messages")
        let childReference = databaseReference.childByAutoId()
        if let toId = user?.id, let fromId = Auth.auth().currentUser?.uid, let message = messageTextField.text {
            let timestamp = NSNumber(value: Date().timeIntervalSince1970)
            let values = ["text": message, "toId": toId,"fromId": fromId,"timestamp": timestamp] as [String : Any]
            childReference.updateChildValues(values) { (error, dbRef) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                let senderMessageRef = Database.database().reference().child("user_messages").child(fromId)
                let messageId = childReference.key
                senderMessageRef.updateChildValues([messageId:1])
                let recipientMessageRef = Database.database().reference().child("user_messages").child(toId)
                recipientMessageRef.updateChildValues([messageId:1])
            }
            messageTextField.text = nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendAction(sendButton)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let maxLength = text.utf16.count + string.utf16.count - range.length
        sendButton.isEnabled = maxLength > 0
        return true
    }
    
    fileprivate func observeUserMessages() {
        messages.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userMessagesReference = Database.database().reference().child("user_messages").child(uid)
        userMessagesReference.observe(.childAdded, with: { (dataSnapshot) in
            let messageId = dataSnapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)
                    if message.chatPartnerId() == self.user?.id {
                        //Just to get the user specific messages from all message from that user
                        self.messages.append(message)
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    // CollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        return cell
    }
    
    // CollectionView Delegate Flow Layout

    func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.size.width, height: 60)
    }
}
