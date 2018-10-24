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
    
    let outgoingAvatarOverlap: CGFloat = 17.5
    
    let refreshControl = UIRefreshControl()
    
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
        dataManager = FIRChat.shared
        dataManager?.configure(.dev, googleInfoFilePath: nil, delegate: self)
    }
    
    @objc
    func loadMoreMessages() {
        refreshControl.endRefreshing()
        
        // Load through network
        // Insert to first index of local list
        // Make list reload & keep offset
        // Force refresh control end refreshing
        
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
//            SampleData.shared.getAdvancedMessages(count: 20) { messages in
//                self.messageList.insert(contentsOf: messages, at: 0)
//
//                DispatchQueue.main.async {
//                    self.messagesCollectionView.reloadDataAndKeepOffset()
//                    self.refreshControl.endRefreshing()
//                }
//            }
//        }
    }

    func sendMessage(_ message: Message) {
        dataManager?.sendMessage(message)
    }
    
    func insertMessage(_ message: Message) {
        messageList.append(message)
        
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }

    // MARK: UICollectionViewDataSource
    
    public override func collectionView(_ collectionView: UICollectionView,
                                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(CustomCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
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
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
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
    func onReceiveMessage(_ message: Message) {
        insertMessage(message)
    }
        
    func onSendMessage(_ message: Message) {
        LOG("=> Did sent message")
    }
    
    func onError(_ error: Error?) {
        LOG("[ERROR] \(error?.localizedDescription ?? "")")
    }
}
