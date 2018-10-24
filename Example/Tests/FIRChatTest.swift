//
//  FIRChatTest.swift
//  ChatExampleTests
//
//  Created by neacao on 10/23/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import Quick
import Nimble
import Firebase
import FirebaseFirestore
@testable import ChatExample

class FIRChatTest: QuickSpec {
    override func spec() {
        
        describe("FIRChat") {
            continueAfterFailure = false
            var instance: FIRChat?
            var mockDelegate: FIRChatTestMock?
            
            beforeEach {
                mockDelegate = FIRChatTestMock()
                instance = FIRChat.shared
                instance?.configure(.dev, googleInfoFilePath: nil, delegate: mockDelegate)
            }
            
            context("onSubscribeChannel") {
                let owner = User(id: "subscribe sender id", name: "subscribe sender name")
                let mockMessage = Message(id: "messageID", content: "subscribe content", owner: owner)
                
                beforeEach {
                    instance?.subscribeChannel("subscribeID")
                }
                
                it("Receive previous messages") {
                    expect(instance).toNot(beNil())
                    expect(mockDelegate).toNot(beNil())
                    expect(mockDelegate!._error).toEventually(beFalse(), timeout: 2)
                    expect(mockDelegate!._received).toEventually(beTrue(), timeout: 2)
                    expect(mockDelegate!._msgReceived).toEventuallyNot(beNil(), timeout: 2)
                    expect(mockDelegate!._msgReceived).toEventually(equal(mockMessage), timeout: 2)
                }
            }
            
        }
    }

}

// MARK: Mock delegate
class FIRChatTestMock: FIRChatDelegate {
    
    var _sent           : Bool = false
    var _received       : Bool = false
    var _msgReceived    : Message? = nil
    var _error          : Bool = false
    
    func onError(_ error: Error?) {
        print("[TEST] got error: \(error!.localizedDescription)")
        _error = true
    }
    
    func onReceiveMessage(_ message: Message) {
        _msgReceived = message
        _received = true
    }
    
    func onSendMessage(_ message: Message) {
        _sent = true
    }
}
