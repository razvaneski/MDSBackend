//
//  BaseService.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import UIKit
import RxSwift
import SwiftyJSON

class BaseService {
    let localStorage = LocalStorage()
    
    var token: String {
        return localStorage.getString(key: .userToken)
    }
}
