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
    
    func getRepairshop(repairshopId: String) -> Single<Repairshop> {
        return RepairshopsAPI.shared.getRepairshop(token: token, repairshopId: repairshopId)
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
    
    func getLockedIntervals(repairshopId: String) -> Single<[LockedInterval]> {
        return RepairshopsAPI.shared.getLockedIntervals(token: token, repairshopId: repairshopId)
    }
    
    func addLockedInterval(startDate: Date, endDate: Date) -> Completable {
        return RepairshopsAPI.shared.addLockedInterval(token: token, startDate: startDate, endDate: endDate)
    }
    
    func removeLockedInterval(lockedIntervalId: String) -> Completable {
        return RepairshopsAPI.shared.removeLockedInterval(token: token, lockedIntervalId: lockedIntervalId)
    }
}
