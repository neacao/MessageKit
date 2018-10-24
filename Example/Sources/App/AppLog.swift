//
//  AppLog.swift
//  ChatExample
//
//  Created by neacao on 10/24/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import Foundation

public func LOG(_ message: String, file: String = #file, function: String = #function)  {
    let message = "[NEA] \(file) \(function) : \(message)"
    print(message)
}
