//
//  message.swift
//  FirebaseLoginAppPractise
//
//  Created by Mraj singh on 26/03/18.
//  Copyright © 2018 Mraj singh. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var text:String?
    var timeStamp:TimeInterval?
    var toId:String?
    var imageURL:String?
    var imageHeight: CGFloat?
    var imageWidht:CGFloat?
    
    func checkPartnerId() -> String? {
         return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }

}
