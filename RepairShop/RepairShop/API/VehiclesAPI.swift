//
//  VehiclesAPI.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 07.05.2023.
//

import UIKit
import Alamofire
import SwiftyJSON
import RxSwift

class VehiclesAPI: BaseAPI {
    static let shared = VehiclesAPI()
    
    private override init() {
        super.init()
    }
    
    func getVehicles(token: String) -> Single<[Vehicle]> {
        let headers = ["token": token]
        
        return call(endpoint: "getvehicles", method: .get, headers: headers) { json in
            return json.arrayValue.map { vehicleJson in
                Vehicle(
                    vin: vehicleJson["vin"].stringValue,
                    licensePlate: vehicleJson["license_plate"].stringValue,
                    make: vehicleJson["make"].stringValue,
                    model: vehicleJson["model"].stringValue,
                    year: vehicleJson["year"].intValue
                )
            }
        }
    }
    
//    func getVehicle(id: String) -> Single<Vehicle> {
//
//    }
    
    func addVehicle(
        token: String,
        vin: String,
        licensePlate: String,
        make: String,
        model: String,
        year: Int) -> Completable {
            let headers = ["token": token]
            let params = [
                "vin": vin,
                "license_plate": licensePlate,
                "make": make,
                "model": model,
                "year": String(year)
            ]
            
            return call(endpoint: "addvehicle", method: .post, params: params, headers: headers) { _ in
                
            }.asCompletable()
    }
}
