//
//  AppointmentsAPI.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 20.05.2023.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class AppointmentsAPI: BaseAPI {
    static let shared = AppointmentsAPI()
    
    private override init() {
        super.init()
    }
    
    func getUserAppointments(token: String) -> Single<[Appointment]> {
        let headers = ["token": token]
        
        return call(endpoint: "getuserappointments", method: .get, headers: headers) { json in
            return json.arrayValue.map { wrapperJson in
                let appointmentJson = wrapperJson["appointment"]
                return Appointment(
                    id: appointmentJson["_id"].stringValue,
                    vehicle: {
                        let vehicleJson = wrapperJson["vehicle"]
                        return Vehicle(
                            id: vehicleJson["_id"].stringValue,
                            vin: vehicleJson["vin"].stringValue,
                            licensePlate: vehicleJson["license_plate"].stringValue,
                            make: vehicleJson["make"].stringValue,
                            model: vehicleJson["model"].stringValue,
                            year: Int(vehicleJson["year"].stringValue)!
                        )
                    }(),
                    repairshop: {
                        let repairshopJson = wrapperJson["repairshop"]
                        return Repairshop(
                            id: repairshopJson["_id"].stringValue,
                            name: repairshopJson["repairshop_name"].stringValue,
                            address: repairshopJson["repairshop_address"].stringValue,
                            phone: repairshopJson["repairshop_phone"].stringValue,
                            email: repairshopJson["repairshop_email"].stringValue,
                            website: repairshopJson["repairshop_website"].stringValue
                        )
                    }(),
                    date: {
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                        return df.date(from: appointmentJson["appointment_date"].stringValue)!
                    }(),
                    status: .init(rawValue: appointmentJson["appointment_status"].stringValue)!
                )
            }
        }
    }
    
    func changeAppointmentStatus(token: String, id: String, newStatus: Appointment.Status) -> Completable {
        let headers = ["token": token]
        let params = ["appointment_status": newStatus.rawValue]
        
        return call(endpoint: "updateappointmentstatus?id=\(id)", method: .post, params: params, headers: headers, responseProcessor: { _ in
            //
        }).asCompletable()
    }
    
//    func getRepairshopAppointments(token: String) -> Single<[Appointment]> {
//        
//    }
    
//    func addAppointment(token: String)
//    func updateAppointmentStatus
}
