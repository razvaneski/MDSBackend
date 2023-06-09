//
//  User.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import Foundation

enum UserType: String {
    case user = "user"
    case repairShop = "repairshop"
}

struct UserInfo {
    let id: String
    let firstName: String
    let lastName: String
    let userName: String
    let userType: UserType
    let token: String
}
