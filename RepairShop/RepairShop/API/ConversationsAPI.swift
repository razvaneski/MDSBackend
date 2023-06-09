//
//  ConversationsAPI.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 21.05.2023.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift

class ConversationsAPI: BaseAPI {
    static let shared = ConversationsAPI()
    
    private override init() {
        super.init()
    }
    
    func getConversations(token: String) -> Single<[Conversation]> {
        let headers = ["token": token]
        
        return call(endpoint: "getconversations", method: .get, headers: headers) { json in
            return json.arrayValue.map { conversationJson in
                return Conversation(
                    userId: conversationJson["user_id"].stringValue,
                    userName: conversationJson["user_name"].stringValue,
                    repairshopId: conversationJson["repairshop_id"].stringValue,
                    repairshopName: conversationJson["repairshop_name"].stringValue,
                    messages: {
                        return conversationJson["messages"].arrayValue.map { messageJson in
                            return Conversation.Message(
                                userId: messageJson["user_id"].stringValue,
                                message: messageJson["message"].stringValue,
                                date: {
                                    let df = ISO8601DateFormatter()
                                    df.formatOptions.insert(.withFractionalSeconds)
                                    return df.date(from: messageJson["date"].stringValue)!
                                }()
                            )
                        }
                    }()
                )
            }
        }
    }
    
    func sendMessage(token: String, message: String, receiverId: String) -> Single<Conversation> {
        let headers = ["token": token]
        
        let params = ["message": message]
        
        return call(endpoint: "sendmessage?receiver_id=\(receiverId)", method: .post, params: params, headers: headers) { conversationJson in
            return Conversation(
                userId: conversationJson["user_id"].stringValue,
                userName: conversationJson["user_name"].stringValue,
                repairshopId: conversationJson["repairshop_id"].stringValue,
                repairshopName: conversationJson["repairshop_name"].stringValue,
                messages: {
                    return conversationJson["messages"].arrayValue.map { messageJson in
                        return Conversation.Message(
                            userId: messageJson["user_id"].stringValue,
                            message: messageJson["message"].stringValue,
                            date: {
                                let df = ISO8601DateFormatter()
                                df.formatOptions.insert(.withFractionalSeconds)
                                return df.date(from: messageJson["date"].stringValue)!
                            }()
                        )
                    }.sorted(by: {$0.date < $1.date})
                }()
            )
        }
    }
    
    func getConversation(token: String, receiverId: String) -> Single<Conversation> {
        let headers = ["token": token]
        
        return call(endpoint: "getconversation?receiver_id=\(receiverId)", method: .get, headers: headers) { conversationJson in
            return Conversation(
                userId: conversationJson["user_id"].stringValue,
                userName: conversationJson["user_name"].stringValue,
                repairshopId: conversationJson["repairshop_id"].stringValue,
                repairshopName: conversationJson["repairshop_name"].stringValue,
                messages: {
                    return conversationJson["messages"].arrayValue.map { messageJson in
                        return Conversation.Message(
                            userId: messageJson["user_id"].stringValue,
                            message: messageJson["message"].stringValue,
                            date: {
                                let df = ISO8601DateFormatter()
                                df.formatOptions.insert(.withFractionalSeconds)
                                return df.date(from: messageJson["date"].stringValue)!
                            }()
                        )
                    }.sorted(by: {$0.date < $1.date})
                }()
            )
        }
    }
}
