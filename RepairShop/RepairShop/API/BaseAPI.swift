//
//  BaseApi.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

enum Environment: String {
    case dev = "http://localhost:4001/"
    // case dev = heroku link cand il vom pune 
}

enum NetworkError: Error {
    case httpErrorCode(code: Int)
}

typealias ResponseProcessor<T> = (JSON) throws -> T

class BaseAPI {
    func call<T>(
        endpoint: String,
        method: HTTPMethod = .get,
        query: [String: String]? = nil,
        params: [String: String]? = nil,
        headers: [String: String]? = nil,
        responseProcessor: @escaping ResponseProcessor<T>
    ) -> Single<T> {
        Single.create { observer in
            let request = AF.request(
                "\(Environment.dev.rawValue)\(endpoint)",
                method: method,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: HTTPHeaders(headers ?? [:])
            )
            request.responseData { data in
                if let error = data.error {
                    observer(.failure(error))
                } else {
                    do {
                        if (200..<299).contains(data.response?.statusCode ?? 0) {
                            if data.data?.count == 0 {
                                let emptyJson = JSON(arrayLiteral: [])
                                observer(.success(try responseProcessor(emptyJson)))
                                return
                            }
                            let result = try responseProcessor(try JSON(data: data.data!))
                            observer(.success(result))
                        } else {
                            throw NetworkError.httpErrorCode(code: data.response?.statusCode ?? 500)
                        }
                    } catch (let error) {
                        observer(.failure(error))
                    }
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
