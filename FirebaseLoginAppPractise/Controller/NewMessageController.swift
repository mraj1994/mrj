//
//  NewMessageController.swift
//  FirebaseLoginAppPractise
//
//  Created by Mraj singh on 21/03/18.
//  Copyright © 2018 Mraj singh. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId  = "cellId"
    var users = [Users]()
    var messagesViewController: MessagesController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        self.navigationItem.title = "New Message"
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUserDetails()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        if let imageUrl  = user.profileImage {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
        } else {
            cell.profileImageView.image = nil
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
 
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesViewController?.showChatController(user:user)
        }
    }
}



extension NewMessageController {
    @objc func cancelButtonTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchUserDetails(){
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any]{
                let user = Users()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImage = dictionary["profileImageURL"] as? String
                user.id = snapshot.key
                self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
}


