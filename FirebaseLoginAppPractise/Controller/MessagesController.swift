//
//  ViewController.swift
//  FirebaseLoginAppPractise
//
//  Created by Mraj singh on 19/03/18.
//  Copyright © 2018 Mraj singh. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    var messages = [Message]()
    var messageDictionary = [String : Message]()
    var users = [Users]()
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target:self, action: #selector(logout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(newButtonTapped))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        checkIfuserIsLoggedIn()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let message = messages[indexPath.row]
        guard let chatpartnerId = message.checkPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("Users").child(chatpartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {
                return
            }
            let user = Users()
            user.name = dictionary["name"] as? String
            user.email = dictionary["email"] as? String
            user.profileImage = dictionary["profileImageURL"] as? String
            user.id = chatpartnerId
            self.showChatController(user:user)
        }, withCancel: nil)
    }
}

extension MessagesController {
    
    func observUserMessages() {
        guard let uid  = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("User_messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            Database.database().reference().child("User_messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessageFromMessageId(messageId: messageId)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private func fetchMessageFromMessageId(messageId:String) {
        let messageReference = Database.database().reference().child("messages").child(messageId)
        messageReference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any] {
                let message = Message()
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? Double
                message.toId = dictionary["toId"] as? String
                if let chatUserId = message.checkPartnerId() {
                    self.messageDictionary[chatUserId] = message
                }
                self.attemptReloadTableView()
            }
        }, withCancel: nil)
    }
    
    private func attemptReloadTableView() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleTableReload), userInfo: nil, repeats: false)
    }
    
    @objc func handleTableReload() {
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timeStamp!.hashValue > message2.timeStamp!.hashValue
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func logout() {
        do {
            try Auth.auth().signOut()
        } catch let errorLogout {
            print(errorLogout)
        }
        
        let loginController = LogInViewController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    
    
    func checkIfuserIsLoggedIn(){
         // user is not logged in..
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(logout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    

    func fetchUserAndSetupNavBarTitle(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any] {
                let user = Users()
                user.name = dictionary["name"] as? String
                user.profileImage = dictionary["profileImageURL"] as? String
                self.setUpNavBarWithUser(user:user)
            }
        })

    }
    
    
    func setUpNavBarWithUser(user:Users) {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        observUserMessages()
        
        self.navigationItem.title = user.name
        
        //setup navigationBar view
        let titleView = UIButton()
        titleView.isUserInteractionEnabled = true
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        if let profileImageUrl = user.profileImage {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        // contraint for container view
        containerView.centerXAnchor.constraint(equalTo:titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        // set Constraint for nav bar image view
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        //set nav bar title
        let namelabel = UILabel()
        namelabel.text = user.name
        namelabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(namelabel)
        
        //set constraint for name label
        namelabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        namelabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        namelabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        namelabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
   
        self.navigationItem.titleView = titleView
        
    }
    
    
    @objc func showChatController(user:Users) {
        let chatLogController = ChatLogViewController(collectionViewLayout:UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    
    @objc func newButtonTapped(){
        let newMsgCntrl = NewMessageController()
        newMsgCntrl.messagesViewController = self
        let navController = UINavigationController(rootViewController: newMsgCntrl)
        present(navController, animated: true, completion: nil)
    }
}

