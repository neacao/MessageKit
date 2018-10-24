//
//  FIRError.swift
//  ChatExample
//
//  Created by neacao on 10/24/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import Foundation

enum FIRError: Error {
    case didNotConfigure
    case invalidUserID
    case invalidChannelID
    case invalidSubscribeChannel
    case invalidMessagePackage([String: Any])
    case unknown
}

extension FIRError {
    var error: NSError? {
        let domain = "com.neacao.firerror"
        
        switch self {
        case .didNotConfigure:
            return NSError(domain: domain, code: 1, userInfo: [NSLocalizedDescriptionKey: "FIRChat did not configure yet"])
            
        case .invalidChannelID:
            return NSError(domain: domain, code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid channel id"])
            
        case .invalidUserID:
            return NSError(domain: domain, code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid user id"])
            
        case .invalidSubscribeChannel:
            return NSError(domain: domain, code: 4, userInfo: [NSLocalizedDescriptionKey: "Channel had not been subscribed yet"])
            
        case .invalidMessagePackage(let data):
            return NSError(domain: domain, code: 5, userInfo: [NSLocalizedDescriptionKey: "Invalid message package \(data)"])
            
        default:
            return nil
        }
    }
}
