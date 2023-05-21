//
//  ConversationMessagesViewModel.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 21.05.2023.
//

import Foundation
import RxSwift

enum ConversationMessagesViewModelEvent {}

class ConversationMessagesViewModel: BaseViewModel<ConversationMessagesViewModelEvent> {
    private var initialConversation: Conversation!
    
    lazy var conversation = Variable<Conversation>(initialConversation)
    
    var isCurrentUserRepairshop: Bool {
        return UserService.shared.currentUserInfo.userType == .repairShop
    }
    
    var currentUserId: String {
        return UserService.shared.currentUserInfo.id
    }
    
    init(initialConversation: Conversation) {
        super.init()
        self.initialConversation = initialConversation
    }
    
    func sendMessage(_ message: String) {
        let receiverId = isCurrentUserRepairshop ? conversation.value.userId : conversation.value.repairshopId
        self.stateSubject.onNext(.loading)
        ConversationsService.shared.sendMessage(receiverId: receiverId, message: message)
            .asObservable()
            .subscribe { [weak self] conversation in
                self?.stateSubject.onNext(.idle)
                self?.conversation.value = conversation
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
}
