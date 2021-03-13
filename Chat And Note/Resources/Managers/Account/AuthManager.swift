//
//  AuthManager.swift
//  Chat And Note
//
//  Created by  Vitalii on 11.03.2021.
//

import Foundation
import FirebaseAuth

class AuthManager {
    
    /// Shared instance of class
    static let shared = AuthManager()
    private init() {}
    
    public func isLoggedIn() -> Bool {
        return FirebaseAuth.Auth.auth().currentUser != nil ? true : false
    }
    
    public func logIn(with email: String, password: String, completion: @escaping (Result<Any, Error>) -> Void) {
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else {
                        return
                    }
                    CacheManager.shared.saveFullName(firstName: firstName, lastName: lastName)
                case .failure(let error):
                    completion(.failure(error))
                }
            })
            
            CacheManager.shared.saveEmail(email: email)
            print("Logged In User: \(user)")
            completion(.success(user))
        })
        
    }
    
    public func logInWithFacebook(with token: String, completion: @escaping (Result<Any, Error>) -> Void) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
            
            guard let result = authResult, error == nil else {
                if let error = error {
                    completion(.failure(error))
                }
                return
            }
            
            completion(.success(result))
        }
    }
    
    public func logInWithGoogle(idToken: String, accessToken: String, completion: @escaping (Result<Any, Error>) -> Void) {
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
            
            guard let result = authResult, error == nil else {
                if let error = error {
                    completion(.failure(error))
                }
                return
            }
            
            completion(.success(result))
        }
    }
    
    public func register(user: AppUser, password: String, image: UIImage?, completion: @escaping (Result<Any, Error>) -> Void) {
        
        DatabaseManager.shared.userExists(with: user.emailAddress) { exists in
            
            guard !exists else {
                completion(.failure(AuthError.accountExists))
                return
            }
            
            // Firebase Register
            FirebaseAuth.Auth.auth().createUser(withEmail: user.emailAddress, password: password) { authResult, error in
                
                guard authResult != nil, error == nil else {
                    completion(.failure(AuthError.userCreation))
                    return
                }
                
                CacheManager.shared.saveEmail(email: user.emailAddress)
                CacheManager.shared.saveFullName(firstName: user.firstName, lastName: user.lastName)
                
                DatabaseManager.shared.insertUser(with: user, completion: { success in
                    if success {
                        // upload image
                        guard let image = image,
                              let data = image.pngData() else {
                            return
                        }
                        let filename = user.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                CacheManager.shared.saveProfilePictureURL(url: downloadUrl)
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        })
                    }
                    completion(.failure(AuthError.userCreation))
                })
                completion(.success(user))
            }
        }
    }
    
    public func logOut() {
        
        CacheManager.shared.deleteName()
        CacheManager.shared.deleteEmail()
        
        FacebookManager.shared.logOut()
        GoogleManager.shared.logOut()
        
        do {
            try FirebaseAuth.Auth.auth().signOut()
        }
        catch {
            print("Failed to log out")
        }
    }
}

public enum AuthError: Error {
    case accountExists
    case userCreation

    public var localizedDescription: String {
        switch self {
        case .accountExists:
            return "Looks like a user account for that email adress already exists."
        case .userCreation:
            return "Error creating user"
        }
    }
}
