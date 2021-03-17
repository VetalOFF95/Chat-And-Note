//
//  DatabaseError.swift
//  Chat And Note
//
//  Created by  Vitalii on 15.03.2021.
//

import Foundation

public enum DatabaseError: Error {
    case failedToFetch

    public var localizedDescription: String {
        switch self {
        case .failedToFetch:
            return "Failed to fetch data from remote database"
        }
    }
}
