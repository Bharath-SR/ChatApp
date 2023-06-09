//
//  Message.swift
//  ChatApp
//
//  Created by YE002 on 02/06/23.
//


import UIKit
import Firebase

struct Message {
    let text : String
    let toId: String
    let fromId: String
    var timestamp : Timestamp!
    var user: User?
    
    let isFromCurrentUser: Bool
    
    var chatpartnerId : String {

        return isFromCurrentUser ? toId : fromId
    }


    init(dictionary : [String:Any]){
        self.text = dictionary["text"] as? String ?? ""
        self.toId = dictionary["told"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
        self.isFromCurrentUser = fromId == Auth.auth().currentUser?.uid
        
        
    }
}

struct Conversation {
    let user : User
    let message : Message
}

