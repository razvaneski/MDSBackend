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
}
