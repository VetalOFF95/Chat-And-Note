//
//  ConversationsVM.swift
//  Chat And Note
//
//  Created by  Vitalii on 11.03.2021.
//

import Foundation

class ConversationsVM {
    
    public func createNewConversation(result: SearchResult) -> ChatViewController {
        let name = result.name
        let email = DatabaseManager.safeEmail(emailAddress: result.email)

        // Check in db if conversation with these two users exists
        // if it does, reuse conversation id
        // otherwise use existing code

        let vc = ChatViewController(with: email, id: nil)
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        
        DatabaseManager.shared.conversationExists(with: email, completion: { result in
            switch result {
            case .success(let conversationId):
                vc.conversationId = conversationId
                vc.isNewConversation = false
            case .failure(_):
                vc.isNewConversation = true
            }
        })
        return vc
    }
}
