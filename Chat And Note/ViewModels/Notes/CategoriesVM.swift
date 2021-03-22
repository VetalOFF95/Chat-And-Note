//
//  CategoriesVM.swift
//  Chat And Note
//
//  Created by  Vitalii on 22.03.2021.
//

import Foundation

class CategoriesVM {
    
    var categories = [String]()
    
    public func fetchCategories(completion: @escaping () -> Void) {
        
        categories = [String]()
        
        guard let email = CacheManager.shared.getEmail() else {
            return
        }
        
        DatabaseManager.shared.fetchNotes(for: email) { [weak self] notes in
            for note in notes {
                self?.categories.append(note.parentCategory)
            }
            self?.categories = Array(Set(self!.categories))
            completion()
        }
    }
    
    public func addCategory(title: String) {
        categories.append(title)
    }
    
    public func getNumberOfCategories() -> Int {
        return categories.count
    }
    
    public func getCategory(for indexPath: IndexPath) -> String {
        return categories[indexPath.row]
    }
}
