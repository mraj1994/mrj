//
//  ChatMessagesViewCell.swift
//  FirebaseLoginAppPractise
//
//  Created by Mraj singh on 31/03/18.
//  Copyright © 2018 Mraj singh. All rights reserved.
//

import UIKit

class ChatMessagesViewCell: UICollectionViewCell {
    
    var chatLogController:ChatLogViewController?
    
    let textView:UITextView = {
        let tv = UITextView()
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.white
        tv.backgroundColor = UIColor.clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 16)
        return tv
    }()
    
    var profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorConstants.KChatBubbleBlueColor
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //set message Image View
    lazy var messageImageView :UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled  = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOnTap)))
        return  imageView
    }()
    
    @objc func handleZoomOnTap(tapGesture:UITapGestureRecognizer){
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    var bubbleWidthAnchor:NSLayoutConstraint?
    var bubbleRightAnchor:NSLayoutConstraint?
    var bubbleViewLeftAnchor:NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        
        // Constaint for message image view
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        //Constraints for bubble view
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant:-8)
        bubbleRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.profileImageView.rightAnchor,constant:8)
        //bubbleViewLeftAnchor?.isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //Constraints for text view
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor,constant:8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        //Constraints for image View
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
