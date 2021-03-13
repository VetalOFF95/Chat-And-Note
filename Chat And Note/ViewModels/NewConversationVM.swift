//
//  NewConversationVM.swift
//  Chat And Note
//
//  Created by  Vitalii on 13.03.2021.
//

import Foundation

class NewConversationVM {
    
    private var results = [SearchResult]()
    private var users = [[String: String]]()
    private var hasFetched = false
    
    public func getNumberOfSearchResults() -> Int {
        return results.count
    }
    
    public func getSearchResultModel(forIndexPath indexPath: IndexPath) -> SearchResult {
        return results[indexPath.row]
    }
    
    public func removeAllSearchResults() {
        results.removeAll()
    }
    
    public func isSearchResultsEmpty() -> Bool {
        return results.isEmpty
    }
    
    public func searchUsers(with query: String, completion: @escaping () -> ()) {
        // check if array has firebase results
        if hasFetched {
            // if it does: filter
            filterUsers(with: query)
        } else {
            fetchAndFilterUsers(with: query, completion: completion)
        }
    }
    
    private func fetchAndFilterUsers(with query: String, completion: @escaping () -> ()) {
        DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
            switch result {
            case .success(let usersCollection):
                self?.hasFetched = true
                self?.users = usersCollection
                self?.filterUsers(with: query)
                completion()
            case .failure(let error):
                print("Failed to get useres: \(error)")
            }
        })
    }
    
    private func filterUsers(with term: String) {
        // update the UI: eiteher show results or show no results label
        guard let currentUserEmail = CacheManager.shared.getEmail(),
              hasFetched else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let filterResults: [SearchResult] = users.filter({
            guard let email = $0["email"],
                  email != safeEmail,
                  let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let email = $0["email"],
                  let name = $0["name"] else {
                return nil
            }
            return SearchResult(name: name, email: email)
        })
        
        results = filterResults
    }
}
