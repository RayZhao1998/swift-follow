//
//  Reads.swift
//  FollowAPI
//
//  Created by ZiyuanZhao on 2024/10/19.
//

import Foundation

public enum Reads {
    public struct GetReadsResponse: Codable, Sendable {
        public let code: Int
        public let data: [String: Int]
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
}
