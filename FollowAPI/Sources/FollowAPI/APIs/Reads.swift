//
//  Reads.swift
//  FollowAPI
//
//  Created by ZiyuanZhao on 2024/10/19.
//

import Foundation
import Alamofire

public enum Reads {
    public struct GetReadsResponse: Codable, Sendable {
        public let code: Int
        public let data: [String: Int]
    }
    
    public struct BasicResponse: Codable, Sendable {
        public let code: Int
    }
}

public actor ReadsService {
    public init() {}

    public func getReads(view: SingleOrArray<String>? = nil) async throws -> Reads.GetReadsResponse {
        let url = NetworkManager.baseURL.appendingPathComponent("reads")
        var parameters = [String: Sendable]()
        if let view {
            switch view {
            case .single(let id):
                parameters["view"] = id
            case .array(let ids):
                parameters["view"] = ids
            }
        }

        return try await NetworkManager.shared.request(url, method: .get, parameters: parameters)
    }
    
    public func deleteReads(entryId: String, isInbox: Bool? = nil) async throws -> Reads.BasicResponse {
        let url = NetworkManager.baseURL.appendingPathComponent("reads")
        var parameters: [String: Sendable] = ["entryId": entryId]
        if let isInbox {
            parameters["isInbox"] = isInbox
        }
        
        return try await NetworkManager.shared.request(
            url,
            method: .delete,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
    
    public func postReads(
        entryIds: [String],
        isInbox: Bool? = nil,
        readHistories: [String]? = nil
    ) async throws -> Reads.BasicResponse {
        let url = NetworkManager.baseURL.appendingPathComponent("reads")
        var parameters: [String: Sendable] = ["entryIds": entryIds]
        if let isInbox {
            parameters["isInbox"] = isInbox
        }
        if let readHistories {
            parameters["readHistories"] = readHistories
        }
        
        return try await NetworkManager.shared.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}
