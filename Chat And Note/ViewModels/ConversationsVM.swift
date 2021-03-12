//
//  ConversationsVM.swift
//  Chat And Note
//
//  Created by  Vitalii on 11.03.2021.
//

import Foundation

class ConversationsVM {
    
    private var conversations = [Conversation]()
    private var loginObserver: NSObjectProtocol?
    
    public func getConversations() -> [Conversation] {
        return conversations
    }
    
    public func getNumberOfConversations() -> Int {
        return conversations.count
    }
    
    public func getConversationModel(forIndexPath indexPath: IndexPath) -> Conversation {
        return conversations[indexPath.row]
    }
    
    public func removeConversationModel(forIndexPath indexPath: IndexPath) {
        conversations.remove(at: indexPath.row)
    }
    
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
    
    public func startListeningForConversations(completion: @escaping (Result<[Conversation], Error>) -> Void) {
        guard let email = CacheManager.shared.getEmail() else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("Starting conversation fetch...")
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                self?.conversations = conversations
                completion(.success(conversations))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    public func addLoginObserver() {
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { _ in
            print("Added login observer")
        })
    }
}
