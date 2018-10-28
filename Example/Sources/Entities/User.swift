//
//  User.swift
//  ChatExample
//
//  Created by neacao on 10/24/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import Foundation

struct User {
    
    let id: String
    let name: String
    let avatarUrl: String
    
    init(id: String, name: String, avatarUrl: String) {
        self.id = id
        self.name = name
        self.avatarUrl = avatarUrl
    }
    
    init?(json: [String: Any]?) {
        guard let senderID = json?[FIRChatKey.Sender.id.str] as? String,
            let senderName = json?[FIRChatKey.Sender.name.str] as? String
            else { return nil }
        
        let avatarUrl = json?[FIRChatKey.Sender.avatarUrl.str] as? String ?? ""
        self.init(id: senderID, name: senderName, avatarUrl: avatarUrl)
    }
}

extension User: DatabasePresentation {
    var representation: [String: Any] {
        return [
            FIRChatKey.Sender.id.str: id,
            FIRChatKey.Sender.name.str: name,
            FIRChatKey.Sender.avatarUrl.str: avatarUrl
        ]
    }
}
