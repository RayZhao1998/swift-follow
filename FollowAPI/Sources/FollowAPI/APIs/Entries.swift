//
//  Entries.swift
//  FollowAPI
//
//  Created by ZiyuanZhao on 2024/10/15.
//

import Alamofire
import Foundation

// MARK: - Request Model

public struct PostEntriesRequest: Encodable, Sendable {
    public let view: Int?
    public let feedId: String?
    public let listId: String?
    public let isArchived: Bool?
    public let csrfToken: String

    public init(feedId: String? = nil, listId: String? = nil, view: Int? = nil, isArchived: Bool? = nil) {
        self.feedId = feedId
        self.listId = listId
        self.view = view
        self.isArchived = isArchived
        self.csrfToken = APIConfig.csrfToken
    }
}

// MARK: - Response Models

public enum PostEntries {
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

public enum GetEntries {
    public struct EntriesResponse: Decodable, Sendable {
        public let code: Int
        public let data: EntriesData?
    }

    public struct EntriesData: Decodable, Sendable {
        public let entries: Entry
        public let feeds: Feed
    }

    public struct Entry: Decodable, Identifiable, Sendable {
        public let description: String?
        public let title: String?
        public let content: String?
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

    public struct Media: Decodable, Sendable {
        public let type: MediaType
        public let url: String
        public let width: Int?
        public let height: Int?
        public let preview_image_url: String?
        public let blurhash: String?
    }

    public enum MediaType: String, Decodable, Sendable {
        case photo, video
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
}

// MARK: - Network Request

public actor EntriesService {
    public init() {}

    public func postEntries(feedId: String? = nil, listId: String? = nil, view: Int? = nil, isArchived: Bool? = nil) async throws -> PostEntries.Response {
        let url = APIConfig.baseURL.appendingPathComponent("entries")
        let parameters = PostEntriesRequest(feedId: feedId, listId: listId, view: view, isArchived: isArchived)

        return try await AF.request(url,
                                    method: .post,
                                    parameters: parameters,
                                    encoder: JSONParameterEncoder.default,
                                    headers: HTTPHeaders(APIConfig.headers))
            .validate()
            .serializingDecodable(PostEntries.Response.self)
            .value
    }

    public func getEntry(id: String) async throws -> GetEntries.EntriesResponse {
        let url = APIConfig.baseURL.appendingPathComponent("entries")

        return try await AF.request(url, method: .get, parameters: ["id": id], encoder: URLEncodedFormParameterEncoder.default, headers: HTTPHeaders(APIConfig.headers))
            .validate()
            .serializingDecodable(GetEntries.EntriesResponse.self)
            .value
    }
}

// Usage example:
// let service = EntriesService()
//
// Task {
//     do {
//         let response = try await service.postEntries(view: 1, isArchived: false)
//         print(response)
//     } catch {
//         print("Error: \(error)")
//     }
// }
