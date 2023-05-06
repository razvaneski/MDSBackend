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
}

class UserService: BaseService {
    static let shared = UserService()
    
    private let localStorage = LocalStorage()
    
    private override init() {
        super.init()
    }
    
    private var token: String {
        return localStorage.getString(key: .userToken)
    }
    
    let userInfo = Variable<UserInfo?>(nil)
    
    func login(username: String, password: String) -> Completable {
        return UserAPI.shared.login(username: username, password: password)
            .do(onSuccess: { response in
                self.userInfo.value = response
                // TODO: set token in userdefaults
            }).asCompletable()
    }
    
    func getUserInfo() -> Completable {
        if token.isEmpty { return Completable.error(ApplicationError.invalidToken) }
        return UserAPI.shared.getUserInfo(token: token).asCompletable()
    }
}
