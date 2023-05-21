//
//  ConversationsViewModel.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 21.05.2023.
//

import Foundation
import RxSwift

enum ConversationsViewModelEvent {}

class ConversationsViewModel: BaseViewModel<ConversationsViewModelEvent> {
    let conversations = Variable<[Conversation]?>(nil)
    
    var isCurrentUserRepairshop: Bool {
        return UserService.shared.currentUserInfo.userType == .repairShop
    }
    
    override init() {
        super.init()
        
    }
    
    func getConversations() {
        stateSubject.onNext(.loading)
        ConversationsService.shared.getConversations()
            .asObservable()
            .subscribe { [weak self] conversations in
                self?.stateSubject.onNext(.idle)
                self?.conversations.value = conversations
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
}
