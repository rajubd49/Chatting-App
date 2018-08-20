//
//  MessageLogController.swift
//  Chatting App
//
//  Created by Raju on 8/6/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class MessageLogController: UIViewController,UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var tappedImageViewFrame: CGRect?
    var blackBackgroundView: UIView?
    var selectedImageView: UIImageView?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
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
                self.scrollToBottom()
            }
        }
    }
    
    var selectedImage: UIImage? {
        didSet{
            uploadMessageImage(selectedImage: selectedImage) { (imageUrl) in
                self.sendImage(imageUrl: imageUrl, image:self.selectedImage!)
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
        
        //UIButton "Send Image"
        containerView.addSubview(uploadMediaButton)
        uploadMediaButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        uploadMediaButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadMediaButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        uploadMediaButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
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
        messageTextField.leftAnchor.constraint(equalTo: uploadMediaButton.rightAnchor, constant: 8).isActive = true
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
    
    let uploadMediaButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "uploadimage"), for: .normal)
        button.addTarget(self, action: #selector(uploadMediaButtonAction), for: .touchUpInside)
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
        if let message = messageTextField.text {
            let properties: [String : Any] = ["text": message]
            sendMessageWithProperties(properties: properties)
        }
    }
    
    // MARK: - Upload Image To Firebase Storage
    private func uploadMessageImage(selectedImage:UIImage?, complition:@escaping (_ imageUrl:String)->()) {
        let imageName = UUID().uuidString
        let storageReference = Storage.storage().reference().child("message_images").child("\(imageName).png")
        if let image = selectedImage, let imageData = UIImageJPEGRepresentation(image, 0.1) {
            storageReference.putData(imageData, metadata: nil, completion: { (storageMetadata, error) in
                if error != nil { print(error!); return }
                storageReference.downloadURL(completion: { (url, error) in
                    if error != nil { print(error!); return }
                    if let imageUrlString = url?.absoluteString {
                        complition(imageUrlString)
                    }
                })
            })
        }
    }
    
    // MARK: - Send Image
    private func sendImage(imageUrl: String, image: UIImage) {
        
        let properties: [String : Any] = ["imageUrl": imageUrl,
                                      "imageWidth": image.size.width,
                                      "imageHeight": image.size.height]
        sendMessageWithProperties(properties: properties)
    }
    
    // MARK: - Send Message With Appropriate Properties
    private func sendMessageWithProperties(properties:[String:Any]) {
        let databaseReference = Database.database().reference().child("messages")
        let childReference = databaseReference.childByAutoId()
        if let toId = user?.id, let fromId = Auth.auth().currentUser?.uid {
            let timestamp = NSNumber(value: Date().timeIntervalSince1970)
            var values: [String : Any] = ["toId": toId,
                                          "fromId": fromId,
                                          "timestamp": timestamp]
            //Key $0, Value $1
            properties.forEach({values[$0] = $1})
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
        setupCell(cell: cell, message: message)
        return cell
    }
    
    // MARK: - CollectionView Delegate Flow Layout
    func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text {
            height = getEstimatedFrameForText(text: text).height + 24 //Padding
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            //height1/width1 = height2/width2
            //So Find, height1 = height2/width2 * width1
            height = CGFloat(imageHeight/imageWidth * 200)
        }
        return CGSize(width: getViewWidth(), height: height)
    }
    
    // MARK: - Utils
    private func setupCell(cell:MessageCell, message: Message) {
        
        cell.messageLogController = self
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
        
        if let messageText = message.text {
            cell.messageTextView.text = messageText
            cell.messageTextView.isHidden = false
            cell.messageImageView.isHidden = true
            cell.messageBubbleWidthAnchor?.constant = getEstimatedFrameForText(text: message.text ?? "").width + 24 //Padding
        } else {
            guard let imageUrl = message.imageUrl else {
                return
            }
            cell.messageImageView.loadImage(urlString: imageUrl)
            cell.messageTextView.isHidden = true
            cell.messageImageView.isHidden = false
            cell.messageBubbleView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            cell.messageBubbleWidthAnchor?.constant = 200
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        cell.message = message
    }
    
    private func getEstimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000) //Your view's width and height value
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey : UIFont.systemFont(ofSize: 15)], context: nil)
    }
    
    private func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
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
            scrollToBottom()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        collectionView.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0, 58, 0)
    }
    
    // MARK: - Perform Image Tap Action
    func messageImageViewDidTap(tappedImageView: UIImageView) {
        
        if let imageViewFrame = tappedImageView.superview?.convert(tappedImageView.frame, to: nil) {
            tappedImageViewFrame = imageViewFrame
            selectedImageView = tappedImageView
            selectedImageView?.isHidden = true
            let zoomingImageView = UIImageView(frame: imageViewFrame)
            zoomingImageView.image = tappedImageView.image
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOutTappedImage)))
            
            if let keyWindow = UIApplication.shared.keyWindow {
                blackBackgroundView = UIView(frame: keyWindow.frame)
                blackBackgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                blackBackgroundView?.alpha = 0
                
                keyWindow.addSubview(blackBackgroundView!)
                keyWindow.addSubview(zoomingImageView)
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.blackBackgroundView?.alpha = 1
                    self.inputContainerView.alpha = 0
                    let imageViewHeight = imageViewFrame.height/imageViewFrame.width * keyWindow.frame.width
                    zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: imageViewHeight)
                    zoomingImageView.center = keyWindow.center
                }, completion: nil)
            }
        }
    }
    
    @objc func zoomOutTappedImage(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView =  tapGesture.view as? UIImageView, let tappedImageViewFrame = tappedImageViewFrame {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = tappedImageViewFrame
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }) { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.selectedImageView?.isHidden = false
            }
        }
    }
    
    func messageVideoViewDidTap(message: Message, bubbleView: UIView) {
        if let videoUrl = message.videoUrl, let url = URL(string: videoUrl) {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player!)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
        }
    }
    
    func removePlayerLayer() {
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
}

extension MessageLogController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func uploadMediaButtonAction() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerController Delegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            handleSelectedVideoWithUrl(videoUrl: videoUrl)
        } else {
            handleSelectedImageWithInfo(info: info)
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func handleSelectedImageWithInfo(info:[String:Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedImage = editedImage as? UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImage = originalImage as? UIImage
        }
    }
    
    private func handleSelectedVideoWithUrl(videoUrl:URL) {
        let videoName = UUID().uuidString
        let storageReference = Storage.storage().reference().child("message_videos").child("\(videoName).mov")
        let uploadTask = storageReference.putFile(from: videoUrl, metadata: nil) { (storageMetadata, error) in
            if error != nil { print(error!); return }
            storageReference.downloadURL(completion: { (url, error) in
                if error != nil { print(error!); return }
                if let videoUrlString = url?.absoluteString {
                    let thumbnailImage = self.generateThumbnailImageFromVideoUrl(videoFileUrl: videoUrl)
                    self.uploadMessageImage(selectedImage: thumbnailImage, complition: { (imageUrl) in
                        
                        let properties: [String : Any] = ["imageUrl": imageUrl,
                                                          "imageWidth": thumbnailImage.size.width,
                                                          "imageHeight": thumbnailImage.size.height,
                                                          "videoUrl":videoUrlString]
                        self.sendMessageWithProperties(properties: properties)
                    })
                }
            })
        }
        uploadTask.observe(.progress) { (snapshot) in
            print(snapshot.progress?.completedUnitCount ?? "")
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("Upload task completed")
        }
    }
    
    private func generateThumbnailImageFromVideoUrl(videoFileUrl: URL) -> UIImage {
        let asset = AVAsset(url: videoFileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let time = CMTimeMakeWithSeconds(1.0, 60)
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print(error.localizedDescription)
        }
        return UIImage()
    }
    
}
