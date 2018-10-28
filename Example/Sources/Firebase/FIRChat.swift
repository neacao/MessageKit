//
//  FIRChat.swift
//  ChatExample
//
//  Created by neacao on 10/23/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import Firebase
import FirebaseFirestore

class FIRChat: NSObject {
    /// In-app
    static let shared: FIRChat = FIRChat()
    private var appContext: AppContext!
    private weak var delegate: FIRChatDelegate?
    
    /// Firebase
    private var db: Firestore!
    
    private var channelRef: CollectionReference?
    
    private var channelListener: ListenerRegistration?
    
    /// Helper
    
    // The start point (top cursor) to query more old messages
    private var lastDocumentCached: QueryDocumentSnapshot!
    
    // Ensure that Firebase just configure at the first time
    private var isConfigured: Bool = false
}

// MARK: Public APIs

extension FIRChat {
    func configure(_ appContext: AppContext,
                   delegate: FIRChatDelegate?) {
        
        // Using default configuration of firebase
        if !isConfigured {
            isConfigured = true
            FirebaseApp.configure()
        }
        
        self.appContext = appContext
        self.delegate = delegate
        self.db = Firestore.firestore()
        
        let settings = self.db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        self.db.settings = settings
        
        LOG("""
            - appContext: \(appContext.rawValue)
            - delegate: \(delegate.debugDescription))
            """)
    }
    
    @discardableResult
    func subscribeChannel(_ channelID: String) -> Self {
        let channel = (appContext == .release ? "channels" : "channelsTest")
        let msgPath = "\(channel)/\(channelID)/messages"
        channelRef = db.collection(msgPath)
        
        channelListener = channelRef?
            .order(by: FIRChatKey.Message.createdAt.str, descending: false)
            .addSnapshotListener { snapshot, error in
                self.handleNewSnapshot(snapshot, error: error)
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

// MARK: Private APIs

extension FIRChat {
    func handleOldSnapshot(_ snapshot: QuerySnapshot?, error: Error?) {
        if let _error = error {
            self.delegate?.onError(_error)
            return
        }
        
        let messages: [Message] = snapshot?.documents.compactMap { change in
            let id = change.documentID
            let json = change.data()
            return Message(id: id, json: json)
        } ?? []
        
        if messages.isEmpty { return }
        
        self.delegate?.onLoadMoreMessages(messages)
    }
    
    func handleNewSnapshot(_ snapshot: QuerySnapshot?, error: Error?) {
        if let _error = error {
            self.delegate?.onError(_error)
            return
        }
        
        snapshot?.documentChanges.forEach { change in
            self.handleDocumentChange(change)
        }
    }
    
    func handleDocumentChange(_ diff: DocumentChange) {
        let document = diff.document
        let json = document.data()
        let id = document.documentID
        
        guard let message = Message(id: id, json: json) else {
            let error = FIRError.invalidMessagePackage(document.data()).error
            self.delegate?.onError(error)
            return
        }
        
        switch diff.type {
        case .added:
            self.delegate?.onReceiveMessage(message)
            
        default: // Will support modified/removed later
            break
        }
    }
}
