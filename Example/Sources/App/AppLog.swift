//
//  AppLog.swift
//  ChatExample
//
//  Created by neacao on 10/24/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import Foundation

public func LOG(_ message: String, file: String = #file, function: String = #function) {
    let prefix = (AppSetting.appContext == .test ? "[TEST]" : "[NEA]")
    let message = "\(prefix) \(file) \(function) : \(message)"
    print(message)
}
