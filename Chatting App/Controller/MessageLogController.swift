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
        collectionView.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
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
            scrollToBottomForMessages()
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
        cell.messageTextView.text = message.text
        cell.messageBubbleWidthAnchor?.constant = getEstimatedFrameForText(text: message.text ?? "").width + 24 //Padding 24
        return cell
    }
    
    // CollectionView Delegate Flow Layout

    func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        if let text = messages[indexPath.item].text {
            height = getEstimatedFrameForText(text: text).height + 16 //Padding 16
        }
        return CGSize(width: view.bounds.size.width, height: height)
    }
    
    private func getEstimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000) //Your view's width and height value
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey : UIFont.systemFont(ofSize: 15)], context: nil)
    }
    
    private func scrollToBottomForMessages() {
        let lastMessageIndex = collectionView.numberOfItems(inSection: 0) - 1
        collectionView.scrollToItem(at: IndexPath(item: lastMessageIndex, section: 0), at: .bottom, animated: true)
    }
}
