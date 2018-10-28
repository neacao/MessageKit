//
//  FIRChat+Interface.swift
//  ChatExample
//
//  Created by neacao on 10/28/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

protocol FIRChatDelegate: class {
    func onLoadMoreMessages(_ messages: [Message])
    func onReceiveMessage(_ message: Message)
    func onSendMessage(_ message: Message)
    func onError(_ error: Error?)
}

enum FIRChatKey {
    enum Message: String {
        case id
        case content
        case contentType
        case createdAt
        case updatedAt
        
        var str: String {
            return self.rawValue
        }
    }
    
    enum Sender: String {
        case id
        case name
        case avatarUrl
        
        var str: String {
            return self.rawValue
        }
    }
}
