//
//  ProfileViewModel.swift
//  Chat And Note
//
//  Created by  Vitalii on 09.03.2021.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
