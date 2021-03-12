//
//  CacheManager.swift
//  Chat And Note
//
//  Created by  Vitalii on 11.03.2021.
//

import Foundation

// Manager to set and get current user data on device
class CacheManager {
    
    /// Shared instance of class
    static let shared = CacheManager()
    private init() {}
    
//    public func saveFullName(name: String) {
//        UserDefaults.standard.set(name, forKey: "name")
//    }
    
    public func saveFullName(firstName: String, lastName: String) {
        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
    }
    
    public func saveEmail(email: String) {
        UserDefaults.standard.set(email, forKey: "email")
    }
    
    public func saveProfilePictureURL(url: String) {
        UserDefaults.standard.set(url, forKey: "profile_picture_url")
    }
    
    public func getName() -> String? {
        return UserDefaults.standard.value(forKey: "name") as? String
    }
    
    public func getEmail() -> String? {
        return UserDefaults.standard.value(forKey: "email") as? String
    }
}
