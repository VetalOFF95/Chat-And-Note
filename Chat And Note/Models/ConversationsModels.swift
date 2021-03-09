//
//  ConversationsModels.swift
//  Chat And Note
//
//  Created by  Vitalii on 09.03.2021.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
