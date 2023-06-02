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
                id: json["_id"].stringValue,
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
                id: json["_id"].stringValue,
                firstName: json["first_name"].stringValue,
                lastName: json["last_name"].stringValue,
                userName: json["username"].stringValue,
                userType: .init(rawValue: json["user_type"].stringValue)!,
                token: json["token"].stringValue
            )
        }
    }
    
    func signUp(firstName: String, lastName: String, username: String, password: String, userType: String) -> Single<UserInfo> {
        let params = [
            "first_name": firstName,
            "last_name": lastName,
            "username": username,
            "password": password,
            "user_type": userType
        ]
        
        return call(endpoint: "register", method: .post, params: params) { json in
            return UserInfo(
                id: json["_id"].stringValue,
                firstName: json["first_name"].stringValue,
                lastName: json["last_name"].stringValue,
                userName: json["username"].stringValue,
                userType: .init(rawValue: json["user_type"].stringValue)!,
                token: json["token"].stringValue
            )
        }
    }
    
    func getRepairShops(token: String) -> Single<[Repairshop]> {
        let headers = ["token": token]
        
        return call(endpoint: "getrepairshops", method: .get, headers: headers) { json in
            return json.arrayValue.map { repairshopJson in
                return Repairshop(
                    id: repairshopJson["_id"].stringValue,
                    name: repairshopJson["repairshop_name"].stringValue,
                    address: repairshopJson["repairshop_address"].stringValue,
                    phone: repairshopJson["repairshop_phone"].stringValue,
                    email: repairshopJson["repairshop_email"].stringValue,
                    website: repairshopJson["repairshop_website"].stringValue
                )
            }
        }
    }
}
