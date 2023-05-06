//
//  UserAPI.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift

class UserAPI: BaseAPI {
    static let shared = UserAPI()
    
    private override init() {
        super.init()
    }
    
    func login(username: String, password: String) -> Single<UserInfo> {
        let params = ["username": username, "password": password]
        
        return call(endpoint: "login", method: .post, params: params) { json in
            return UserInfo(
                firstName: json["first_name"].stringValue,
                lastName: json["last_name"].stringValue,
                userName: json["username"].stringValue,
                userType: .init(rawValue: json["user_type"].stringValue)!,
                token: json["token"].stringValue
            )
        }
    }
    
    func getUserInfo(token: String) -> Single<UserInfo> {
        let headers = ["token": token]
        
        return call(endpoint: "getuser", method: .get, headers: headers) { json in
            return UserInfo(
                firstName: json["first_name"].stringValue,
                lastName: json["last_name"].stringValue,
                userName: json["username"].stringValue,
                userType: .init(rawValue: json["user_type"].stringValue)!,
                token: json["token"].stringValue
            )
        }
    }
}
