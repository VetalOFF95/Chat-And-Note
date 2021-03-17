//
//  ProfileVM.swift
//  Chat And Note
//
//  Created by  Vitalii on 13.03.2021.
//

import Foundation

class ProfileVM {
    
    var profileData = [ProfileDataVM]()
    
    public func addData(_ data: ProfileDataVM) {
        profileData.append(data)
    }
    
    public func getNumberOfDataItems() -> Int {
        return profileData.count
    }
    
    public func getProfileDataVM(forIndexPath indexPath: IndexPath) -> ProfileDataVM {
        return profileData[indexPath.row]
    }
    
}
