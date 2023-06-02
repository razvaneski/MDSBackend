//
//  MyAppointmentsViewModel.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 20.05.2023.
//

import Foundation
import RxSwift

enum AppointmentsViewModelEvent {}

class AppointmentsViewModel: BaseViewModel<AppointmentsViewModelEvent> {
    let appointments = Variable<[Appointment]?>(nil)
    
    init(userType: UserType) {
        super.init()
        getAppointments(userType)
    }
    
    func getAppointments(_ userType: UserType) {
        self.stateSubject.onNext(.loading)
        switch userType {
        case .user:
            AppointmentsService.shared.getUserAppointments()
                .asObservable()
                .subscribe { [weak self] appointments in
                    self?.stateSubject.onNext(.idle)
                    self?.appointments.value = appointments.sorted(by: {$0.date < $1.date})
                } onError: { [weak self] error in
                    self?.stateSubject.onNext(.idle)
                    self?.errorSubject.onNext(error)
                }.disposed(by: disposeBag)
        case .repairShop:
            AppointmentsService.shared.getRepairshopAppointments()
                .asObservable()
                .subscribe { [weak self] appointments in
                    self?.stateSubject.onNext(.idle)
                    self?.appointments.value = appointments.sorted(by: {$0.date < $1.date})
                } onError: { [weak self] error in
                    self?.stateSubject.onNext(.idle)
                    self?.errorSubject.onNext(error)
                }.disposed(by: disposeBag)
        }
    }
}
