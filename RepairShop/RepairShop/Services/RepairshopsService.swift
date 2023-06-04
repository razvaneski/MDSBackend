//
//  RepairshopsService.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 04.06.2023.
//

import Foundation
import RxSwift

class RepairshopsService: BaseService {
    static let shared = RepairshopsService()
    
    private override init() {
        super.init()
    }
    
    func getRepairshops() -> Single<[Repairshop]> {
        return RepairshopsAPI.shared.getRepairShops(token: token)
    }
    
    func getReviews(repairshopId: String) -> Single<[Review]> {
        return RepairshopsAPI.shared.getReviews(token: token, repairshopId: repairshopId)
    }
    
    func addReview(repairshopId: String, rating: Int, message: String) -> Completable {
        return RepairshopsAPI.shared.addReview(token: token, repairshopId: repairshopId, rating: rating, message: message)
    }
}
