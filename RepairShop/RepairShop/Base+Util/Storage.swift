//
//  Storage.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import Foundation

enum StorageKey: String {
    case userToken = "token"
}

class LocalStorage {
    private let userDefaults = UserDefaults.standard
    
    func getString(key: StorageKey) -> String {
        return userDefaults.string(forKey: key.rawValue) ?? ""
    }
    
    func setString(_ string: String, key: StorageKey) {
        userDefaults.set(string, forKey: key.rawValue)
    }
}
