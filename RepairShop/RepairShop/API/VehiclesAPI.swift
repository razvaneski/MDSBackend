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
                    id: vehicleJson["_id"].stringValue,
                    userId: vehicleJson["user_id"].stringValue,
                    vin: vehicleJson["vin"].stringValue,
                    licensePlate: vehicleJson["license_plate"].stringValue,
                    make: vehicleJson["make"].stringValue,
                    model: vehicleJson["model"].stringValue,
                    year: vehicleJson["year"].intValue
                )
            }
        }
    }
    
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
    
    func getVehicle(token: String, id: String) -> Single<Vehicle> {
        let headers = ["token": token]
        
        return call(endpoint: "getvehicle?id=\(id)", method: .get, headers: headers) { json in
            return Vehicle(
                id: json["_id"].stringValue,
                userId: json["user_id"].stringValue,
                vin: json["vin"].stringValue,
                licensePlate: json["license_plate"].stringValue,
                make: json["make"].stringValue,
                model: json["model"].stringValue,
                year: json["year"].intValue
            )
        }
    }
    
    func updateVehicle(token: String, id: String, make: String, model: String, year: Int, vin: String, licensePlate: String) -> Completable {
        let headers = ["token": token]
        
        let params = [
            "make": make,
            "model": model,
            "year": String(year),
            "vin": vin,
            "license_plate": licensePlate
        ]
        
        return call(endpoint: "updatevehicle?id=\(id)", method: .post, params: params, headers: headers) { _ in
            //
        }.asCompletable()
    }
    
    func deleteVehicle(token: String, id: String) -> Completable {
        return call(endpoint: "deletevehicle?id=\(id)", method: .post) { _ in
            //
        }.asCompletable()
    }
}
