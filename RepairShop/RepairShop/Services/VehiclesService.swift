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
    
    func getVehicle(id: String) -> Single<Vehicle> {
        return VehiclesAPI.shared.getVehicle(token: token, id: id)
    }
    
    func updateVehicle(id: String, make: String, model: String, year: Int, vin: String, licensePlate: String) -> Completable {
        return VehiclesAPI.shared.updateVehicle(token: token, id: id, make: make, model: model, year: year, vin: vin, licensePlate: licensePlate)
    }
    
    func deleteVehicle(id: String) -> Completable {
        return VehiclesAPI.shared.deleteVehicle(token: token, id: id)
    }
}
