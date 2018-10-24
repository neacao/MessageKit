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
                instance = FIRChat.shared
                mockDelegate = FIRChatTestMock()
                instance?.configure(.dev, googleInfoFilePath: nil, delegate: mockDelegate)
                instance?.subscribeChannel("channelTestID")
            }
            
            afterEach {
                instance?.unsubscribeChannel()
            }
            
            it("receive message") {
                // Enable self script to run this
                expect(instance).toNotEventually(beNil())
                expect(mockDelegate).toNotEventually(beNil())
                expect(mockDelegate!._error).toNotEventually(beTrue(), timeout: 5.0)
                expect(mockDelegate!._received).toEventually(beTrue(), timeout: 5.0)
            }
        }
    }

}

// MARK: Mock delegate
class FIRChatTestMock: FIRChatDelegate {
    
    var _sent       : Bool = false
    var _received   : Bool = false
    var _error      : Bool = false
    
    func onError(_ error: Error?) {
        print("[TEST] got error: \(error!.localizedDescription)")
        _error = true
    }
    
    func onReceiveMessage(_ message: Message) {
        _received = true
    }
    
    func onSendMessage(_ message: Message) {
        _sent = true
    }
}
