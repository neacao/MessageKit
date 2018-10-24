//
//  AppSetting.swift
//  ChatExample
//
//  Created by neacao on 10/24/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import Foundation

final class AppSetting {
    
    private enum Keys: String {
        case userID
        case displayName
    }
    
    static var displayName: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.displayName.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            
            if let name = newValue {
                defaults.setValue(name, forKey: Keys.displayName.rawValue)
            } else {
                defaults.removeObject(forKey: Keys.displayName.rawValue)
            }
        }
    }
    
    static var userID: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.userID.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            
            if let name = newValue {
                defaults.setValue(name, forKey: Keys.userID.rawValue)
            } else {
                defaults.removeObject(forKey: Keys.userID.rawValue)
            }
        }
    }
    
    static var me: User {
        let _name = displayName ?? "<unknown>"
        let _userID = userID ?? UUID().uuidString
        return User(id: _userID, name: _name)
    }
    
}
