//
//  ChatVM.swift
//  Chat And Note
//
//  Created by  Vitalii on 14.03.2021.
//

import Foundation

class ChatVM {
    
    private var messages = [Message]()
    
    public func setMessages(_ messages: [Message]) {
        self.messages = messages
    }
    
    public func getNumberOfMessages() -> Int {
        return messages.count
    }
    
    public func getMessage(forIndexPath indexPath: IndexPath) -> Message {
        return messages[indexPath.section]
    }
}
