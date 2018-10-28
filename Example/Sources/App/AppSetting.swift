//
//  AppSetting.swift
//  ChatExample
//
//  Created by neacao on 10/24/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import Foundation

enum AppContext: Int {
    case dev
    case test
    case release
    case automate
}

final class AppSetting {
    
    private enum Keys: String {
        case userID
        case displayName
        case appContext
        
        var str: String {
            return self.rawValue
        }
    }
    
    static var displayName: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.displayName.str)
        }
        set {
            let defaults = UserDefaults.standard
            
            if let name = newValue {
                defaults.setValue(name, forKey: Keys.displayName.str)
            } else {
                defaults.removeObject(forKey: Keys.displayName.str)
            }
        }
    }
    
    static var userID: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.userID.str)
        }
        set {
            let defaults = UserDefaults.standard
            
            if let name = newValue {
                defaults.setValue(name, forKey: Keys.userID.str)
            } else {
                defaults.removeObject(forKey: Keys.userID.str)
            }
        }
    }
    
    static var me: User {
        let _name = displayName ?? "<unknownUserName>"
        let _userID = userID ?? UUID().uuidString
        return User(id: _userID, name: _name, avatarUrl: "")
    }
    
    static var appContext: AppContext {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: Keys.appContext.str)
            let ret = AppContext(rawValue: rawValue)!
            return ret
        }
        set {
            let defaults = UserDefaults.standard
            let rawValue = newValue.rawValue
            defaults.setValue(rawValue, forKey: Keys.appContext.str)
        }
    }
}
