//
//  AdvanceExampleViewController+Delegate.swift
//  ChatExample
//
//  Created by neacao on 10/21/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import MessageKit
import MessageInputBar
import MapKit

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        inputBar.inputTextView.components.forEach {
            if let str = $0 as? String {
                let message = Message(content: str)
                sendMessage(message)
            }
//            else if let img = component as? UIImage {
//                let message = MockMessage(image: img, sender: currentSender(), messageId: UUID().uuidString, date: Date())
//                insertMessage(message)
//            }
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType,
                   at indexPath: IndexPath,
                   in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType,
                            and message: MessageType,
                            at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType,
                          at indexPath: IndexPath,
                          in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType,
                         at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView,
                             for message: MessageType,
                             at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
//        avatarView.set(avatar: avatar)
//        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
//        avatarView.layer.borderWidth = 2
//        avatarView.layer.borderColor = UIColor.primaryColor.cgColor
        avatarView.isHidden = true
    }
    
//    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
//        guard accessoryView.subviews.isEmpty else { return }
//        let button = UIButton(type: .infoLight)
//        button.tintColor = .primaryColor
//        accessoryView.addSubview(button)
//        button.frame = accessoryView.bounds
//        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
//        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
//        accessoryView.backgroundColor = UIColor.primaryColor.withAlphaComponent(0.3)
//    }
    
//    // MARK: - Location Messages
//
//    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
//        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
//        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
//        annotationView.image = pinImage
//        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
//        return annotationView
//    }
//
//    func animationBlockForLocation(message: MessageType,
//                                   at indexPath: IndexPath,
//                                   in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
//        return { view in
//            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
//            UIView.animate(withDuration: 0.6,
//                           delay: 0,
//                           usingSpringWithDamping: 0.9,
//                           initialSpringVelocity: 0,
//                           options: [],
//                           animations: {
//                view.layer.transform = CATransform3DIdentity
//            }, completion: nil)
//        }
//    }
//
//    func snapshotOptionsForLocation(message: MessageType,
//                                    at indexPath: IndexPath,
//                                    in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
//
//        return LocationMessageSnapshotOptions(showsBuildings: true,
//                                              showsPointsOfInterest: true,
//                                              span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
//    }
    
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
    
}
