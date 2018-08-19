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
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: "MessageCell")
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView.keyboardDismissMode = .interactive
        
        observeKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Input Accessory View
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Prepare Input Container View
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        containerView.frame = CGRect(x: 0, y: 0, width:view.bounds.width, height: 50)
        
        //UIButton "Send"
        sendButton.isEnabled = false
        containerView.addSubview(sendButton)
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        //UITextField "Message Input"
        messageTextField.delegate = self
        containerView.addSubview(messageTextField)
        messageTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        messageTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        messageTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        //UIView "Separator"
        let separatorView = UIView()
        separatorView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorView)
        
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        
        return containerView
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
        button.addTarget(self, action: #selector(sendAction), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Fetch Message Log
    fileprivate func observeUserMessages() {
        messages.removeAll()
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else{
            return
        }
        let userMessagesReference = Database.database().reference().child("user_messages").child(uid).child(toId)
        userMessagesReference.observe(.childAdded, with: { (dataSnapshot) in
            let messageId = dataSnapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)
                    self.messages.append(message)
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }

    // MARK: - UIButton Action
    @objc func sendAction() {
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
                let senderMessageRef = Database.database().reference().child("user_messages").child(fromId).child(toId)
                let messageId = childReference.key
                senderMessageRef.updateChildValues([messageId:1])
                let recipientMessageRef = Database.database().reference().child("user_messages").child(toId).child(fromId)
                recipientMessageRef.updateChildValues([messageId:1])
            }
            messageTextField.text = nil
            sendButton.isEnabled = false
            scrollToBottomForMessages()
        }
    }
    
    // MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendAction()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let maxLength = text.utf16.count + string.utf16.count - range.length
        sendButton.isEnabled = maxLength > 0
        return true
    }
    
    // MARK: - CollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.item]
        cell.messageTextView.text = message.text
        setupCell(cell: cell, message: message)
        cell.messageBubbleWidthAnchor?.constant = getEstimatedFrameForText(text: message.text ?? "").width + 24 //Padding
        return cell
    }
    
    // MARK: - CollectionView Delegate Flow Layout
    func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        if let text = messages[indexPath.item].text {
            height = getEstimatedFrameForText(text: text).height + 24 //Padding
        }
        return CGSize(width: getViewWidth(), height: height)
    }
    
    // MARK: - Utils
    private func setupCell(cell:MessageCell, message: Message) {
        
        if let imageUrl = user?.imageurl {
            cell.profileImageView.loadImage(urlString: imageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //Outgoing blue bubble message from login user
            cell.messageBubbleView.backgroundColor = MessageCell.lightBlueColor
            cell.messageTextView.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.messageBubbleRightAnchor?.isActive = true
            cell.messageBubbleLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true
        } else {
            //Incoming gray bubble message from selected user
            cell.messageBubbleView.backgroundColor = MessageCell.lightGrayColor
            cell.messageTextView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.messageBubbleRightAnchor?.isActive = false
            cell.messageBubbleLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
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
    
    func getViewWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // MARK: - UIKeyboardNotification
    
    func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MessageLogController.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessageLogController.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            collectionView.contentInset = UIEdgeInsetsMake(8, 0, keyboardFrame.height + 8, 0)
            collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0, keyboardFrame.height + 8, 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        collectionView.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0, 58, 0)
    }
    
}
