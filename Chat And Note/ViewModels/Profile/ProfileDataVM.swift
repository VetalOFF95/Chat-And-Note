//
//  ProfileViewModel.swift
//  Chat And Note
//
//  Created by  Vitalii on 09.03.2021.
//

import Foundation

enum ProfileDataViewModelType {
    case info, logout
}

struct ProfileDataVM {
    let viewModelType: ProfileDataViewModelType
    let title: String
    let handler: (() -> Void)?
}
