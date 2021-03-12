//
//  GoogleVM.swift
//  Chat And Note
//
//  Created by  Vitalii on 12.03.2021.
//

import Foundation
import GoogleSignIn

class GoogleVM {
    
    public func signInViaGoogle(for user: GIDGoogleUser) {
        
        guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName else {
            return
        }
        
        let appUser = AppUser(firstName: firstName,
                              lastName: lastName,
                              emailAddress: email)
        
        CacheManager.shared.saveEmail(email: appUser.emailAddress)
        CacheManager.shared.saveFullName(firstName: appUser.firstName, lastName: appUser.lastName)
        
        DatabaseManager.shared.userExists(with: email, completion: { exists in
            if !exists {
                // insert to database
                DatabaseManager.shared.insertUser(with: appUser, completion: { success in
                    if success && user.profile.hasImage {
                        if let url = user.profile.imageURL(withDimension: 200) {
                            insertGoogleUserPicture(user: appUser, imageURL: url)
                        }
                    }
                })
            }
        })
        
        guard let authentication = user.authentication,
              let idToken = authentication.idToken,
              let accessToken = authentication.accessToken else {
            print("Missing auth object off of google user")
            return
        }
        
        AuthManager.shared.logInWithGoogle(idToken: idToken, accessToken: accessToken) { result in
            switch result {
            case .success(_):
                print("Successfully logged user in via Google")
                NotificationCenter.default.post(name: .didLogInNotification, object: nil)
            case .failure(let error):
                print("Failed to log in via Google: \(error)")
            }
        }        
    }
    
}

private func insertGoogleUserPicture(user: AppUser, imageURL: URL) {
    
    URLSession.shared.dataTask(with: imageURL, completionHandler: { data, _, _ in
        guard let data = data else {
            return
        }
        
        StorageManager.shared.uploadProfilePicture(with: data, fileName: user.profilePictureFileName) { result in
            switch result {
            case .success(let downloadUrl):
                CacheManager.shared.saveProfilePictureURL(url: downloadUrl)
            case .failure(let error):
                print("Storage manager error: \(error)")
            }
        }
    }).resume()
}
