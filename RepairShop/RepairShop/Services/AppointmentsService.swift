//
//  AppointmentsService.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 20.05.2023.
//

import Foundation
import RxSwift

class AppointmentsService: BaseService {
    static let shared = AppointmentsService()
    
    private override init() {
        super.init()
    }
    
    func getUserAppointments() -> Single<[Appointment]> {
        return AppointmentsAPI.shared.getUserAppointments(token: token)
    }
    
    func changeAppointmentStatus(id: String, newStatus: Appointment.Status) -> Completable {
        return AppointmentsAPI.shared.changeAppointmentStatus(token: token, id: id, newStatus: newStatus)
    }
}
