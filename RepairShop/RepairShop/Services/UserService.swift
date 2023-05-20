//
//  UserService.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import Foundation
import RxSwift
import SwiftyJSON

enum ApplicationError: Error {
    case invalidToken
    case message(str: String)
}

class UserService: BaseService {
    static let shared = UserService()
    
    private override init() {
        super.init()
    }
    
    
    var currentUserInfo: UserInfo!
    
    func login(username: String, password: String) -> Completable {
        return UserAPI.shared.login(username: username, password: password)
            .do(onSuccess: { [weak self] response in
                self?.currentUserInfo = response
                self?.localStorage.setString(response.token, key: .userToken)
            }).asCompletable()
    }
    
    func getUserInfo() -> Completable {
        if token.isEmpty { return Completable.error(ApplicationError.invalidToken) }
        return UserAPI.shared.getUserInfo(token: token)
            .do { [weak self] userInfo in
                self?.currentUserInfo = userInfo
                self?.localStorage.setString(userInfo.token, key: .userToken)
            }.asCompletable()
    }
    
    func signUp(firstName: String, lastName: String, username: String, password: String, userType: String) -> Completable {
        return UserAPI.shared.signUp(
            firstName: firstName,
            lastName: lastName,
            username: username,
            password: password,
            userType: userType
        ).do { [weak self] userInfo in
            self?.currentUserInfo = userInfo
            self?.localStorage.setString(userInfo.token, key: .userToken)
        }.asCompletable()
    }
}
