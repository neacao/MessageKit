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
    var avatarUrl: String?
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    // Remote data initial
    init?(json: [String: Any]?) {
        guard let senderID = json?["senderID"] as? String,
            let senderName = json?["senderName"] as? String
            else { return nil }
        self.id = senderID
        self.name = senderName
        self.avatarUrl = json?["avatarUrl"] as? String
    }
}

extension User: DatabasePresentation {
    var representation: [String: Any] {
        return [
            "senderID": id,
            "senderName": name
        ]
    }
}
