//
//  FIRChat+Helper.swift
//  ChatExample
//
//  Created by neacao on 10/27/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import FirebaseFirestore

extension Date {
    static func findCreatedAt(from json: [String: Any]?) -> Date? {
        let date = (json?[FIRChatKey.Message.createdAt.str] as? Timestamp)?.dateValue()
        return date
    }
    
    static func findUpdatedAt(from json: [String: Any]?) -> Date? {
        let date = (json?[FIRChatKey.Message.updatedAt.str] as? Timestamp)?.dateValue()
        return date
    }
}
