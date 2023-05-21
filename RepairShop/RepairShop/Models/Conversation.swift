//
//  Conversation.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 21.05.2023.
//

import Foundation

struct Conversation {
    let userId: String
    let userName: String
    let repairshopId: String
    let repairshopName: String
    let messages: [Message]
    
    struct Message {
        let userId: String
        let message: String
        let date: Date
    }
}
