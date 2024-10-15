//
//  Subscriptions.swift
//  FollowAPI
//
//  Created by ZiyuanZhao on 2024/10/14.
//

import Foundation
import Alamofire

// MARK: - Response Structures

public struct SubscriptionsResponse: Codable, Sendable {
    let code: Int
    public let data: [Subscription]
}

public enum Subscription: Codable, Identifiable, Sendable {
    case feed(FeedSubscription)
    case list(ListSubscription)
    case inbox(InboxSubscription)
    
    public var id: String {
        switch self {
        case .feed(let feedSubscription):
            return "feed_\(feedSubscription.feedId)"
        case .list(let listSubscription):
            return "list_\(listSubscription.listId)"
        case .inbox(let inboxSubscription):
            return "inbox_\(inboxSubscription.inboxId)"
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let feedSubscription = try? container.decode(FeedSubscription.self) {
            self = .feed(feedSubscription)
        } else if let listSubscription = try? container.decode(ListSubscription.self) {
            self = .list(listSubscription)
        } else if let inboxSubscription = try? container.decode(InboxSubscription.self) {
            self = .inbox(inboxSubscription)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode subscription")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .feed(let feedSubscription):
            try container.encode(feedSubscription)
        case .list(let listSubscription):
            try container.encode(listSubscription)
        case .inbox(let inboxSubscription):
            try container.encode(inboxSubscription)
        }
    }
}

public struct FeedSubscription: Codable, Sendable {
    public let title: String?
    public let userId: String
    public let view: Int
    public let category: String?
    public let feeds: Feed
    public let feedId: String
    public let isPrivate: Bool
}

public struct ListSubscription: Codable, Sendable {
    public let title: String?
    public let userId: String
    public let view: Int
    public let feedId: String
    public let lists: List
    public let isPrivate: Bool
    public let listId: String
    public let lastViewedAt: String?
    public let category: String?
}

public struct InboxSubscription: Codable, Sendable {
    public let title: String?
    public let userId: String
    public let view: Int
    public let category: String?
    public let feedId: String
    public let inboxId: String
    public let isPrivate: Bool
    public let inboxes: Inbox
}

public struct Feed: Codable, Sendable {
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

public struct List: Codable, Sendable {
    public let type: String
    public let id: String
    public let view: Int
    public let feedIds: [String]
    public let fee: Int
    public let timelineUpdatedAt: String
    public let description: String?
    public let title: String?
    public let image: String?
    public let feeds: [Feed]?
    public let ownerUserId: String?
    public let owner: User?
}

public struct Inbox: Codable, Sendable {
    public let type: String
    public let id: String
    public let secret: String
    public let description: String?
    public let title: String?
    public let image: String?
    public let ownerUserId: String?
    public let owner: User?
}

public struct User: Codable, Sendable {
    public let name: String?
    public let id: String
    public let emailVerified: String?
    public let image: String?
    public let handle: String?
    public let createdAt: String
}

// MARK: - Network Request

public enum StringOrArray {
    case single(String)
    case array([String])
}

// MARK: - Network Request

public enum QueryParameter: Sendable {
    case single(String)
    case array([String])
    
    var urlQueryItem: [URLQueryItem] {
        switch self {
        case .single(let value):
            return [URLQueryItem(name: "", value: value)]
        case .array(let values):
            return values.map { URLQueryItem(name: "", value: $0) }
        }
    }
}

public actor SubscriptionService {
    private let baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    public func getSubscriptions(userId: QueryParameter? = nil, view: QueryParameter? = nil) async throws -> SubscriptionsResponse {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("subscriptions"), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = []
        
        if let userId = userId {
            urlComponents?.queryItems?.append(contentsOf: userId.urlQueryItem.map { URLQueryItem(name: "userId", value: $0.value) })
        }
        
        if let view = view {
            urlComponents?.queryItems?.append(contentsOf: view.urlQueryItem.map { URLQueryItem(name: "view", value: $0.value) })
        }
        
        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await AF.request(url, headers: ["Cookie": "authjs.csrf-token=d5051ca2ef2ff16aa25d9084734784a93e0c5ad4920f2d48b037f68c304a254a%7C504b4d19cdad22c0126377904054446b75092dc7c92597902a6d9b8662602f75; authjs.callback-url=https%3A%2F%2Fapp.follow.is%2Fredirect%3Fapp%3Dfollow; authjs.session-token=e03fa6bc-4763-413a-b2a8-d8dd9a017974; ph_phc_EZGEvBt830JgBHTiwpHqJAEbWnbv63m5UpreojwEWNL_posthog=%7B%22distinct_id%22%3A%2258054760722430976%22%2C%22%24sesid%22%3A%5B1729003155097%2C%220192909b-a66b-74b0-a468-13b80bfb7a8b%22%2C1729002972779%5D%2C%22%24epp%22%3Atrue%7D"])
            .validate()
            .serializingDecodable(SubscriptionsResponse.self)
            .value
    }
}

// Usage example:
// let baseURL = URL(string: "https://your-api-base-url.com")!
// let service = SubscriptionService(baseURL: baseURL)
//
// Task {
//     do {
//         let response = try await service.getSubscriptions(userId: .single("user123"), view: .array(["1", "2"]))
//         print(response)
//     } catch {
//         print("Error: \(error)")
//     }
// }
