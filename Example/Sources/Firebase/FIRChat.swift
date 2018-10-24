//
//  FIRChat.swift
//  ChatExample
//
//  Created by neacao on 10/23/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import FirebaseFirestore

protocol FIRChatDelegate: class {
    func onReceiveMessage(_ message: Message)
    func onSendMessage(_ message: Message)
    func onError(_ error: Error?)
}

class FIRChat: NSObject {
    
    static let shared: FIRChat = FIRChat()

    // MARK: Properties
    
    private var appContext: AppContext!
    
    private let db: Firestore = Firestore.firestore()
    
    private var globalRef: CollectionReference?
    private var channelRef: CollectionReference?
    
    private var globalListener: ListenerRegistration?
    private var channelListener: ListenerRegistration?
    
    private weak var delegate: FIRChatDelegate?
    
    // MARK: Public APIs
    
    func configure(_ appContext: AppContext,
                   googleInfoFilePath path: String?,
                   delegate: FIRChatDelegate?) {
        
        self.appContext = appContext
        self.delegate = delegate
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        LOG("""
            - appContext: \(appContext.rawValue)
            - delegate: \(delegate.debugDescription)
            - googleFilePath: \(path ?? "nil")
            """)
    }
    
    @discardableResult
    func selfSubscribe(_ userID: String) -> Self {
        globalRef = db.collection("users/\(userID)")
        globalListener = globalRef?.addSnapshotListener { snapshot, error in
            self.handleSnapshot(snapshot, error: error)
        }
        
        LOG("""
            - userID: \(userID)
            - globalRef: \(globalRef.debugDescription)
            - globalListener: \(globalListener.debugDescription)")
            """)
        
        return self
    }
    
    @discardableResult
    func subscribeChannel(_ channelID: String) -> Self {
        if appContext == .dev {
            channelRef = db.collection("channelsTest/\(channelID)/messages")
        } else if appContext == .release {
            channelRef = db.collection("channels/\(channelID)/messages")
        }
        
        channelListener = channelRef?.addSnapshotListener { snapshot, error in
            self.handleSnapshot(snapshot, error: error)
        }
        
        LOG("""
            - appContext: \(appContext.rawValue)
            - channelID: \(channelID)
            - channelRef: \(channelRef.debugDescription)
            - channelListener: \(channelListener.debugDescription)")
            """)
        
        return self
    }
    
    @discardableResult
    func unsubscribeChannel() -> Self {
        LOG("- channelListener: \(channelListener.debugDescription)")
        
        channelListener?.remove()
        channelListener = nil
        
        return self
    }
    
    func sendMessage(_ message: Message) {
        guard let ref = channelRef else {
            self.delegate?.onError(FIRError.invalidSubscribeChannel.error)
            return
        }
        
        ref.addDocument(data: message.representation, completion: { (error) in
            if let _error = error {
                self.delegate?.onError(_error)
                
            } else {
                self.delegate?.onSendMessage(message)
            }
        })
    }
}

// MARK: FIRChat Private APIs

extension FIRChat {
    func handleSnapshot(_ snapshot: QuerySnapshot?, error: Error?) {
        if let _error = error {
            self.delegate?.onError(_error)
            return
        }
        
        snapshot?.documentChanges.forEach { change in
            self.handleDocumentChange(change)
        }
    }
    
    func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            let error = FIRError.invalidMessagePackage(change.document.data()).error
            self.delegate?.onError(error)
            return
        }
        
        switch change.type {
        case .added:
            self.delegate?.onReceiveMessage(message)
            
        case .modified:
            //TODO:
            break
            
        case .removed:
            //TODO:
            break
        }
    }
}
