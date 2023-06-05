//
//  RepairshopsAPI.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 04.06.2023.
//

import Foundation
import RxSwift
import SwiftyJSON
import Alamofire

class RepairshopsAPI: BaseAPI {
    static let shared = RepairshopsAPI()
    
    private override init() {
        super.init()
    }
    
    func getRepairshop(token: String, repairshopId: String) -> Single<Repairshop> {
        let headers = ["token": token]
        
        return call(endpoint: "getrepairshop?id=\(repairshopId)", method: .get, headers: headers) { repairshopJson in
            return Repairshop(
                id: repairshopJson["_id"].stringValue,
                name: repairshopJson["repairshop_name"].stringValue,
                address: repairshopJson["repairshop_address"].stringValue,
                phone: repairshopJson["repairshop_phone"].stringValue,
                email: repairshopJson["repairshop_email"].stringValue,
                website: repairshopJson["repairshop_website"].stringValue,
                startTime: repairshopJson["repairshop_start_time"].stringValue,
                endTime: repairshopJson["repairshop_end_time"].stringValue
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
                    website: repairshopJson["repairshop_website"].stringValue,
                    startTime: repairshopJson["repairshop_start_time"].stringValue,
                    endTime: repairshopJson["repairshop_end_time"].stringValue
                )
            }
        }
    }
    
    func getReviews(token: String, repairshopId: String) -> Single<[Review]> {
        let headers = ["token": token]
        
        return call(endpoint: "getreviews?repairshop_id=\(repairshopId)", method: .get, headers: headers) { json in
            return json.arrayValue.map { reviewJson in
                return Review(
                    userId: reviewJson["user_id"].stringValue,
                    repairshopId: reviewJson["repairshop_id"].stringValue,
                    rating: reviewJson["rating"].intValue,
                    message: reviewJson["message"].stringValue
                )
            }
        }
    }
    
    func addReview(token: String, repairshopId: String, rating: Int, message: String) -> Completable {
        let headers = ["token": token]
        let params = [
            "rating": String(rating),
            "message": message
        ]
        
        return call(endpoint: "addreview?repairshop_id=\(repairshopId)", method: .post, params: params, headers: headers) { _ in
            //
        }.asCompletable()
    }
    
    func getLockedIntervals(token: String, repairshopId: String) -> Single<[LockedInterval]> {
        let headers = ["token": token]
        
        return call(endpoint: "getlockedintervals", method: .get, headers: headers) { json in
            return json.arrayValue.map { lockedIntervalJson in
                let df = ISO8601DateFormatter()
                df.formatOptions.insert(.withFractionalSeconds)
                return LockedInterval(
                    id: lockedIntervalJson["_id"].stringValue,
                    startDate: df.date(from: lockedIntervalJson["start_date"].stringValue)!,
                    endDate: df.date(from: lockedIntervalJson["end_date"].stringValue)!
                )
            }
        }
    }
    
    func addLockedInterval(token: String, startDate: Date, endDate: Date) -> Completable {
        let headers = ["token": token]
        let params = [
            "start_date": startDate.ISO8601Format(),
            "end_date": endDate.ISO8601Format()
        ]
        
        return call(endpoint: "addlockedinterval", method: .post, params: params, headers: headers) { _ in
            //
        }.asCompletable()
    }
    
    func removeLockedInterval(token: String, lockedIntervalId: String) -> Completable {
        let headers = ["token": token]
        let params = ["locked_interval_id": lockedIntervalId]
        
        return call(endpoint: "removelockedinterval", method: .post, params: params, headers: headers) { _ in
            //
        }.asCompletable()
    }
}
