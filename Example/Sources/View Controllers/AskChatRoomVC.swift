//
//  AskChatRoomVC.swift
//  ChatExample
//
//  Created by neacao on 10/28/18.
//  Copyright © 2018 MessageKit. All rights reserved.
//

import UIKit

class AskChatRoomVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        let btn = UIButton(type: .custom)
        self.view.addSubview(btn)
        
        btn.addTarget(self, action: #selector(joinChatRoomDidTap), for: .touchUpInside)
        btn.setTitle("Join Chat Room", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        btn.layer.cornerRadius = 25.0
        btn.backgroundColor = UIColor(red: 0, green: 144, blue: 255, alpha: 1)
        btn.center = self.view.center
    }
    
    @objc func joinChatRoomDidTap() {
        let alertVC = UIAlertController(title: "Chat Room ID", message: nil, preferredStyle: .alert)
        alertVC.addTextField { textField in
            textField.placeholder = "Enter chat room id here"
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            let chatRoomID = alertVC.textFields?.first?.text
            self.tryToJoinChat(chatRoomID)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func tryToJoinChat(_ roomID: String?) {
        guard let _roomID = roomID, !_roomID.isEmpty else { return }
        let vc = ChatViewController()
        vc.roomID = roomID
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
