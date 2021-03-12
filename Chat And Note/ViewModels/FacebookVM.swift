//
//  FacebookVM.swift
//  Chat And Note
//
//  Created by  Vitalii on 11.03.2021.
//

import Foundation
import FBSDKLoginKit

class FacebookVM {
    
    public func signInViaFacebook(with token: String, completion: @escaping (Result<Any, Error>) -> Void) {
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields":
                                                                        "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start(completionHandler: { _, result, error in
            
            guard let result = result as? [String: Any],
                  error == nil else {
                print("Failed to make facebook graph request")
                return
            }

            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String else {
                print("Faields to get email and name from fb result")
                return
            }
            
            let appUser = AppUser(firstName: firstName,
                                       lastName: lastName,
                                       emailAddress: email)
            
            CacheManager.shared.saveEmail(email: appUser.emailAddress)
            CacheManager.shared.saveFullName(firstName: appUser.firstName, lastName: appUser.lastName)
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: appUser) { success in
                        if success {
                            self.insertFacebookUserPicture(appUser, pictureUrl: pictureUrl)
                        }
                    }
                }
            }
            
            AuthManager.shared.logInWithFacebook(with: token) { result in
                switch result {
                case .success(_):
                    print("Successfully logged user in via Facebook")
                    completion(.success(result))
                case .failure(let error):
                    print("Failed to log in via Facebook: \(error)")
                    completion(.failure(error))
                }
            }
        })
    }
    
    
    private func insertFacebookUserPicture(_ user: AppUser, pictureUrl: String) {
        
        guard let url = URL(string: pictureUrl) else {
            return
        }

        // Download picture from Facebook
        URLSession.shared.dataTask(with: url, completionHandler: { data, _,_ in
            guard let data = data else {
                print("Failed to get image data from facebook")
                return
            }

            print("got data from FB, uploading...")

            // Upload user picture
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
}
