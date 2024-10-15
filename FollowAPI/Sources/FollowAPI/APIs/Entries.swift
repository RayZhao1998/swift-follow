//
//  Entries.swift
//  FollowAPI
//
//  Created by ZiyuanZhao on 2024/10/15.
//

import Foundation
import Alamofire

// MARK: - Request Model

public struct EntriesRequest: Encodable, Sendable {
    public let view: Int?
    public let isArchived: Bool?
    public let csrfToken: String
    
    public init(view: Int? = nil, isArchived: Bool? = nil) {
        self.view = view
        self.isArchived = isArchived
        self.csrfToken = APIConfig.csrfToken
    }
}

// MARK: - Response Models

public enum Entries {
    public struct Response: Decodable, Sendable {
        public let code: Int
        public let remaining: Int
        public let data: [EntryData]?
        public let total: Int?
    }

    public struct EntryData: Decodable, Sendable, Identifiable {
        public let entries: Entry
        public let feeds: Feed
        public let read: Bool?
        public let collections: Collections?
        public let settings: Settings?
        
        public var id: String {
            entries.id
        }
    }

    public struct Entry: Decodable, Sendable, Identifiable {
        public let description: String?
        public let title: String?
        public let id: String
        public let author: String?
        public let url: String?
        public let guid: String
        public let categories: [String]?
        public let authorUrl: String?
        public let authorAvatar: String?
        public let insertedAt: String
        public let publishedAt: String
        public let media: [Media]?
        public let attachments: [Attachment]?
        public let extra: Extra?
    }

    public struct Feed: Decodable, Sendable {
        public let type: String
        public let id: String
        public let url: String
        public let description: String?
        public let title: String?
        public let image: String?
        public let siteUrl: String?
        public let errorMessage: String?
        public let errorAt: String?
        public let ownerUserId: String?
        public let owner: User?
        public let tipUsers: [User]?
    }

    public struct User: Decodable, Sendable {
        public let name: String?
        public let id: String
        public let emailVerified: String?
        public let image: String?
        public let handle: String?
        public let createdAt: String
    }

    public struct Media: Decodable, Sendable {
        public let type: String
        public let url: String
        public let width: Int?
        public let height: Int?
        public let preview_image_url: String?
        public let blurhash: String?
    }

    public struct Attachment: Decodable, Sendable {
        public let url: String
        public let title: String?
        public let duration_in_seconds: Int?
        public let mime_type: String?
        public let size_in_bytes: Int?
    }

    public struct Extra: Decodable, Sendable {
        public let links: [Link]?
    }

    public struct Link: Decodable, Sendable {
        public let type: String
        public let url: String
        public let content_html: String?
    }

    public struct Collections: Decodable, Sendable {
        public let createdAt: String
    }

    public struct Settings: Decodable, Sendable {
        public let summary: Bool?
        public let translation: String?
        public let readability: Bool?
        public let silence: Bool?
        public let newEntryNotification: Bool?
        public let rewriteRules: [RewriteRule]?
        public let webhooks: [String]?
    }

    public struct RewriteRule: Decodable, Sendable {
        public let from: String
        public let to: String
    }
}

// MARK: - Network Request

public actor EntriesService {
    public init() {}
    
    public func getEntries(view: Int? = nil, isArchived: Bool? = nil) async throws -> Entries.Response {
        let url = APIConfig.baseURL.appendingPathComponent("entries")
        let parameters = EntriesRequest(view: view, isArchived: isArchived)
        
        return try await AF.request(url, 
                                    method: .post, 
                                    parameters: parameters, 
                                    encoder: JSONParameterEncoder.default,
                                    headers: HTTPHeaders(APIConfig.headers))
            .validate()
            .serializingDecodable(Entries.Response.self)
            .value
    }
}

// Usage example:
// let service = EntriesService()
//
// Task {
//     do {
//         let response = try await service.getEntries(view: 1, isArchived: false)
//         print(response)
//     } catch {
//         print("Error: \(error)")
//     }
// }
