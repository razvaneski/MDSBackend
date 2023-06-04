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
    
    func addReview(token: String, review: Review) -> Completable {
        let headers = ["token": token]
        let params = [
            "rating": String(review.rating),
            "message": review.message
        ]
        
        return call(endpoint: "addReview?repairshop_id=\(review.repairshopId)", method: .post, params: params, headers: headers) { _ in
            //
        }.asCompletable()
    }
}
