//
//  Entries.swift
//  FollowAPI
//
//  Created by ZiyuanZhao on 2024/10/15.
//

import Alamofire
import Foundation

// MARK: - Request Model

func getUrlIcon(url: String, fallback: Bool? = nil) -> (src: String, fallbackUrl: String) {
    var src = ""
    var fallbackUrl = ""

    if let urlObj = URL(string: url) {
        let host = urlObj.host ?? ""
        // 注意: 这里需要实现类似 parse 的域名解析功能
        let pureDomain = getPureDomain(from: host)
        fallbackUrl = "https://avatar.vercel.sh/\(pureDomain).svg?text=\(pureDomain.prefix(2).uppercased())"
        src = "https://unavatar.webp.se/\(host)?fallback=\(fallback ?? false)"
    } else {
        let pureDomain = getPureDomain(from: url)
        src = "https://avatar.vercel.sh/\(pureDomain).svg?text=\(pureDomain.prefix(2).uppercased())"
    }

    return (src: src, fallbackUrl: fallbackUrl)
}

func getPureDomain(from host: String) -> String {
    return host.components(separatedBy: ".")[0]
}

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
        self.csrfToken = NetworkManager.shared.csrfToken ?? ""
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
        public var read: Bool?
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

        public var imageUrl: String? {
            if let image {
                return image
            }
            if let siteUrl {
                return getUrlIcon(url: siteUrl).src
            }
            return nil
        }
    }

    public struct User: Decodable, Sendable {
        public let name: String?
        public let id: String
        public let emailVerified: Bool?
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
        public let duration_in_seconds: String?
        public let mime_type: String?
        public let size_in_bytes: String?
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
        public let duration_in_seconds: String?
        public let mime_type: String?
        public let size_in_bytes: String?
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
        public let emailVerified: Bool?
        public let image: String?
        public let handle: String?
        public let createdAt: String
    }
}

// MARK: - Network Request

public actor EntriesService {
    public init() {}

    public func postEntries(feedId: String? = nil, listId: String? = nil, view: Int? = nil, isArchived: Bool = false, read: Bool = false, publishedAfter: String? = nil) async throws -> PostEntries.Response {
        let url = NetworkManager.baseURL.appendingPathComponent("entries")

        var parameters: [String: Sendable] = [:]
        parameters["csrfToken"] = NetworkManager.shared.csrfToken ?? ""
        if let feedId = feedId { parameters["feedId"] = feedId }
        if let listId = listId { parameters["listId"] = listId }
        if let view = view { parameters["view"] = view }
        parameters["isArchived"] = isArchived
        parameters["read"] = read
        if let publishedAfter = publishedAfter { parameters["publishedAfter"] = publishedAfter }

        return try await NetworkManager.shared.request(url,
                                                       method: .post,
                                                       parameters: parameters,
                                                       encoding: JSONEncoding.default)
    }

    public func getEntry(id: String) async throws -> GetEntries.EntriesResponse {
        let url = NetworkManager.baseURL.appendingPathComponent("entries")
        let parameters: [String: Sendable] = ["id": id]

        return try await NetworkManager.shared.request(url,
                                                       method: .get,
                                                       parameters: parameters)
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
