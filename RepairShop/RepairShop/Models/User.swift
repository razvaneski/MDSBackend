//
//  User.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import Foundation

enum UserType: String {
    case user = "user"
    case admin = "admin"
}

struct UserInfo {
    let firstName: String
    let lastName: String
    let userName: String
    let userType: UserType
    let token: String
}
