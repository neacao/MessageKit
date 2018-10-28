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
    let contentType: String
    let owner: User
    let createdAt: Date
    var updatedAt: Date?
    
    private init(id: String, content: String, contentType: String, createdAt: Date, updatedAt: Date?, owner: User) {
        self.id = id
        self.content = content
        self.contentType = contentType
        self.owner = owner
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
    
    init(content: String) {
        // id will be replaced by pushID of Firestore
        self.init(id: "", content: content, contentType: "text", createdAt: Date(), updatedAt: Date(), owner: AppSetting.me)
    }
    
    init?(id: String, json: [String: Any]?) {
        guard let owner = User(json: json),
            let content = json?[FIRChatKey.Message.content.str] as? String,
            let contentType = json?[FIRChatKey.Message.contentType.str] as? String,
            let createdAt = Date.findCreatedAt(from: json)
            else { return nil }
        
        let updatedAt = Date.findUpdatedAt(from: json)
        self.init(id: id, content: content, contentType: contentType, createdAt: createdAt, updatedAt: updatedAt, owner: owner)
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
            FIRChatKey.Sender.id.str: owner.id,
            FIRChatKey.Sender.name.str: owner.name,
            FIRChatKey.Message.content.str: content,
            FIRChatKey.Message.contentType.str: "text",
            FIRChatKey.Message.createdAt.str: createdAt
            ] as [String: Any]
        return data
    }
}

extension Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        guard let lID = lhs.id, let rID = rhs.id, lID == rID else { return false }
        return true
    }
}
