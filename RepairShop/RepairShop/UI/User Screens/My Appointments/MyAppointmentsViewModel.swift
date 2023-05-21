//
//  MyAppointmentsViewModel.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 20.05.2023.
//

import Foundation
import RxSwift

enum MyAppointmentsViewModelEvent {}

class MyAppointmentsViewModel: BaseViewModel<MyAppointmentsViewModelEvent> {
    let appointments = Variable<[Appointment]?>(nil)
    
    override init() {
        super.init()
        getAppointments()
    }
    
    func getAppointments() {
        self.stateSubject.onNext(.loading)
        AppointmentsService.shared.getUserAppointments()
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
