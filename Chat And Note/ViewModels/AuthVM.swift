//
//  AuthVM.swift
//  Chat And Note
//
//  Created by  Vitalii on 11.03.2021.
//

import Foundation
import FirebaseAuth

class AuthVM {
    
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
}
