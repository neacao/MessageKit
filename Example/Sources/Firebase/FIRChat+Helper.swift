//
//  FIRChat+Helper.swift
//  ChatExample
//
//  Created by neacao on 10/27/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import FirebaseFirestore

enum MessageKeys: String {
    case createdAt
}

extension Date {
    static func findCreatedAt(from json: [String: Any]?) -> Date? {
        let date = (json?["createdAt"] as? Timestamp)?.dateValue()
        return date
    }
}
