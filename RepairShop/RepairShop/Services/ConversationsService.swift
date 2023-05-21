//
//  ConversationsService.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 21.05.2023.
//

import Foundation
import RxSwift

class ConversationsService: BaseService {
    static let shared = ConversationsService()
    
    private override init() {
        super.init()
    }
    
    func getConversations() -> Single<[Conversation]> {
        return ConversationsAPI.shared.getConversations(token: token)
    }
    
    func sendMessage(receiverId: String, message: String) -> Single<Conversation> {
        return ConversationsAPI.shared.sendMessage(token: token, message: message, receiverId: receiverId)
    }
}
