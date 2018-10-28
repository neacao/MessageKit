//
//  Message.swift
//  ChatExample
//
//  Created by neacao on 10/24/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import MessageKit

struct Message {
    
    // MARK: Firestore
    var id: String?
    let content: String
    let owner: User
    let createdAt: Date
    
    init(content: String) {
        self.init(id: "", content: content, owner: AppSetting.me)
    }
    
    init(id: String, content: String, owner: User) {
        self.id = id
        self.content = content
        self.createdAt = Date()
        self.owner = owner
    }
    
    init?(id: String, json: [String: Any]?) {
        guard let owner = User(json: json),
            let content = json?["content"] as? String,
            let createdAt = Date.findCreatedAt(from: json)
            else { return nil }
        
        self.id = id
        self.owner = owner
        self.content = content
        self.createdAt = createdAt
    }
}

extension Message: MessageType {
    var sender: Sender {
        return Sender(id: owner.id, displayName: owner.name)
    }
    
    var messageId: String {
        return self.id ?? "<unknownMsgID>"
    }
    
    var sentDate: Date {
        return self.createdAt
    }
    
    var kind: MessageKind {
        return .text(self.content)
    }
}

extension Message: DatabasePresentation {
    var representation: [String: Any] {
        let data = [
            "senderID": owner.id,
            "senderName": owner.name,
            "content": content,
            "createdAt": createdAt
            ] as [String: Any]
        return data
    }
}

extension Message: Equatable {
    static func ==(lhs: Message, rhs: Message) -> Bool {
        guard let lID = lhs.id, let rID = rhs.id, lID == rID else { return false }
        return true
    }
}
