//
//  ChatLogViewController.swift
//  FirebaseLoginAppPractise
//
//  Created by Mraj singh on 25/03/18.
//  Copyright © 2018 Mraj singh. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController: UICollectionViewController,UITextFieldDelegate {
    
    var user: Users? {
        didSet{
            self.navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var msgtextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.backgroundColor = UIColor.white
        textField.returnKeyType  = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    
    let cellId = "CellId"
    var messages = [Message]()
    var containerViewBottomAnchor:NSLayoutConstraint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        self.msgtextField.delegate = self
        collectionView?.register(ChatMessagesViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 56, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 48, 0)
        collectionView?.keyboardDismissMode = .interactive
        setupInputComponents()
        setUpKeyBoardObserver()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        containerViewBottomAnchor?.constant = 0
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    
}

extension ChatLogViewController {
    
    func setUpKeyBoardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoradWillShow), name:.UIKeyboardWillShow, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoradDidShow), name:.UIKeyboardDidShow, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoradwilldismiss), name:.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyBoradWillShow(notification:Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]  as? NSValue)?.cgRectValue
        let keyboradDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboradDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyBoradDidShow(){
        if messages.count > 0 {
            let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0) as IndexPath
            self.collectionView?.scrollToItem(at: indexPath, at:.bottom, animated: true)
        }
    }
    
    @objc func handleKeyBoradwilldismiss(notification:Notification) {
        let keyboradDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboradDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func estimatedHeightForCell(text:String) -> CGRect {
        let size = CGSize(width: 225, height: 1000)
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: option, attributes: [kCTFontAttributeName as NSAttributedStringKey:UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func observeMessages(){
        guard let uid  = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        let userMessageRef = Database.database().reference().child("User_messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String:Any] else {
                    return
                }
                let message = Message()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? Double
                message.toId = dictionary["toId"] as? String
                message.imageURL = dictionary["imageURL"] as? String
                message.imageHeight = dictionary["imageHeight"] as? CGFloat
                message.imageWidht = dictionary["imageWidth"] as? CGFloat
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0) as IndexPath
                    self.collectionView?.scrollToItem(at: indexPath, at:.bottom, animated: false)
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func setupInputComponents(){
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = ColorConstants.KWhiteSmokeColor
        
        view.addSubview(containerView)
        
        //setup contraints for container view
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        
        //set Image view for uploading
        
        //set add button
        let addButton = UIButton(type: .system)
        addButton.setImage(#imageLiteral(resourceName: "add_icon"), for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(openPickerView), for: .touchUpInside)
        
        containerView.addSubview(addButton)
        
        //set send button
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(addMessageToThequeue), for: .touchUpInside)
        
        containerView.addSubview(sendButton)

        
        //set view in which message textField will be there
        let messageView = UIView()
        messageView.clipsToBounds = true
        messageView.layer.cornerRadius = 16
        messageView.backgroundColor = UIColor.white
        messageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(messageView)
        
        //set constraint for message view
        messageView.leftAnchor.constraint(equalTo: addButton.rightAnchor,constant:8).isActive = true
        messageView.rightAnchor.constraint(equalTo: sendButton.leftAnchor,constant:-8).isActive = true
        messageView.topAnchor.constraint(equalTo: containerView.topAnchor,constant:8).isActive = true
        messageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,constant:-8).isActive = true
  
        //set constraint for add button
        addButton.leftAnchor.constraint(equalTo: containerView.leftAnchor,constant:8).isActive = true
        addButton.topAnchor.constraint(equalTo: containerView.topAnchor,constant:9).isActive = true
        addButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,constant:-9).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        //set constraint for send button
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        //set textfield for container view
        messageView.addSubview(msgtextField)
   
        //add contraints for msg text field
        msgtextField.leftAnchor.constraint(equalTo: messageView.leftAnchor,constant:8).isActive = true
        msgtextField.rightAnchor.constraint(equalTo: messageView.rightAnchor).isActive = true
        msgtextField.topAnchor.constraint(equalTo: messageView.topAnchor).isActive = true
        msgtextField.bottomAnchor.constraint(equalTo: messageView.bottomAnchor).isActive = true
     
    }
    
    @objc func openPickerView(){
        let alert  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] (action) in
            self?.openPhotoGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func addMessageToThequeue() {
        let properties:[String:Any] = ["text":msgtextField.text!]
        if msgtextField.text != "" {
            self.sendMessageWithProperties(properties: properties)
            msgtextField.text = ""
        }
    }
    
    private func uploadImageURL(imageURL:String,image:UIImage) {
        
        let properties:[String:Any] = ["imageURL":imageURL,"imageWidth":image.size.width,"imageHeight":image.size.height]
        self.sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties:[String:Any]) {
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = self.user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = Date.timeIntervalSinceReferenceDate
        var values = ["toId":toId,"fromId":fromId,"timeStamp":timeStamp] as [String:Any]
        //key is $0 and value is $1
        properties.forEach({values[$0] = $1})
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            let userMessageRef = Database.database().reference().child("User_messages").child(fromId).child(toId)
            let messageId  = childRef.key
            userMessageRef.updateChildValues([messageId : 1])
            
            
            let receipientUserMessageRef = Database.database().reference().child("User_messages").child(toId).child(fromId)
            receipientUserMessageRef.updateChildValues([messageId : 1])
        }
    }
}

extension ChatLogViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId , for: indexPath) as! ChatMessagesViewCell
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimatedHeightForCell(text: text).width + 30
        } else if message.imageURL != nil {
                cell.bubbleWidthAnchor?.constant = 225
            }
        
        setUpCell(cell: cell, message: message)
        return cell
    }
    
    private func setUpCell(cell: ChatMessagesViewCell,message:Message){
        
        if let profileImage = self.user?.profileImage {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImage)
        }
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ColorConstants.KChatBubbleBlueColor
            cell.profileImageView.isHidden = true
            cell.textView.textColor = UIColor.white
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleRightAnchor?.isActive = true
        } else {
            cell.bubbleView.backgroundColor  = ColorConstants.KChatBubbleGrayColor
            cell.profileImageView.isHidden = false
            cell.textView.textColor = UIColor.black
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleRightAnchor?.isActive = false
        }
        if let messageUrl = message.imageURL {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 80.0
        let message = messages[indexPath.row]
        if let text = message.text {
            height = estimatedHeightForCell(text: text).height + 20
        } else if let imageWidth = message.imageWidht, let imageHeight = message.imageHeight {
                height = imageHeight/imageWidth * 225
            }
        return CGSize(width: view.frame.width, height: height)
    }
}

extension ChatLogViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func openPhotoGallery(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            self.uploadImageToFirebaseStrorage(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadImageToFirebaseStrorage(image:UIImage) {
        let imageName = NSUUID().uuidString
        let storageReference = Storage.storage().reference().child("message_Images").child("\(imageName).jpg")
        if let uploadData = UIImageJPEGRepresentation(image,0.2) {
            storageReference.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    self.uploadImageURL(imageURL: imageURL,image:image)
                }
            }
        }
    }
}



