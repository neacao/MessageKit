/*
 MIT License
 
 Copyright (c) 2017-2018 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import MessageKit

final class ChatViewController: MessagesViewController, MessagesDataSource {
    
    weak var mainclv: MessagesCollectionView!
    
    let outgoingAvatarOverlap: CGFloat = 17.5
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var messageList: [Message]!
    
    private var dataManager: FIRChat?
    
    override func viewDidLoad() {
        messagesCollectionView = MessagesCollectionView(frame: .zero,
                                                        collectionViewLayout: CustomMessagesFlowLayout())
        messagesCollectionView.register(CustomCell.self)
        mainclv = messagesCollectionView
        
        super.viewDidLoad()
        self.setupUI()
        self.setupManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dataManager?.subscribeChannel("subscribeID")
    }
    
    // MARK: - Helpers
    
    func setupManager() {
        messageList = []
        
        if AppSetting.appContext != .test {
            dataManager = FIRChat.shared
            dataManager?.configure(.dev, delegate: self)
        }
    }
    
    @objc
    func loadMoreMessages() {
        
    }

    func sendMessage(_ message: Message) {
        dataManager?.sendMessage(message)
    }
    
    func insertOldMessages(_ messages: [Message]) {
        if messages.isEmpty { return }
        
        messageList.insert(contentsOf: messages, at: 0)
        
        mainclv.performBatchUpdates({
            (0..<messages.count).forEach {
                mainclv.insertSections([$0])
            }
//            if messageList.count >= 2 {
//                mainclv.reloadSections([messageList.count - 2])
//            }
        }, completion: nil)
    }
    
    func addMessage(_ message: Message) {
        messageList.append(message)
        
        // Reload last section to update header/footer labels and insert a new one
        mainclv.performBatchUpdates({
            mainclv.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                mainclv.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.mainclv.scrollToBottom(animated: true)
            }
        })
    }

    // MARK: UICollectionViewDataSource
    
    public override func collectionView(_ collectionView: UICollectionView,
                                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesDataSource = mainclv.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: mainclv)
        if case .custom = message.kind {
            let cell = mainclv.dequeueReusableCell(CustomCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: mainclv)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
}

// MARK: Helpers

extension ChatViewController {
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return mainclv.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].sender == messageList[indexPath.section - 1].sender
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].sender == messageList[indexPath.section + 1].sender
    }
    
    func setTypingIndicatorHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        updateTitleView(title: "MessageKit", subtitle: isHidden ? "2 Online" : "Typing...")
    }
}

// MARK: DataManagerDelegate
extension ChatViewController: FIRChatDelegate {
    func onLoadMoreMessages(_ messages: [Message]) {
        insertOldMessages(messages)
    }
    
    func onReceiveMessage(_ message: Message) {
        LOG("=> createdAt: \(message.createdAt)")
        addMessage(message)
    }
        
    func onSendMessage(_ message: Message) {
        LOG("=> Did sent message")
    }
    
    func onError(_ error: Error?) {
        LOG("[ERROR] \(error?.localizedDescription ?? "")")
    }
}
