//
//  VehiclesService.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 07.05.2023.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class VehiclesService: BaseService {
    static let shared = VehiclesService()
    
    private override init() {
        super.init()
    }
    
    private let localStorage = LocalStorage()
    
    private var token: String {
        return localStorage.getString(key: .userToken)
    }
    
    func getVehicles() -> Single<[Vehicle]> {
        return VehiclesAPI.shared.getVehicles(token: token)
    }
    
    func addVehicle(vin: String, licensePlate: String, make: String, model: String, year: Int) -> Completable {
        return VehiclesAPI.shared.addVehicle(
            token: token,
            vin: vin,
            licensePlate: licensePlate,
            make: make,
            model: model,
            year: year
        )
    }
}
