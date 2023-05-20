//
//  Appointment.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 20.05.2023.
//

import Foundation

struct Appointment {
    let id: String
    let vehicle: Vehicle
    let repairshop: Repairshop
    let date: Date
    let status: Status
    
    enum Status: String {
        case pending
        case declined
        case confirmed
        case completed
        
        case cancelled // Reserved for cancelling by the user
    }
}
