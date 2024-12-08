//
//  Subscriptions.swift
//  FollowAPI
//
//  Created by ZiyuanZhao on 2024/10/14.
//

import Foundation

// MARK: - Response Structures

public enum Subscriptions {
    public struct Response: Codable, Sendable {
        public let code: Int
        public let data: [Subscription]
    }

    public enum Subscription: Codable, Identifiable, Sendable {
        case feed(FeedSubscription)
        case list(ListSubscription)
        case inbox(InboxSubscription)
        
        public var id: String? {
            switch self {
            case .feed(let feedSubscription):
                return "\(feedSubscription.feedId)"
            case .list(let listSubscription):
                return listSubscription.listId == nil ? nil : "\(listSubscription.listId!)"
            case .inbox(let inboxSubscription):
                return "\(inboxSubscription.inboxId)"
            }
        }
        
        public var view: Int? {
            switch self {
            case .feed(let feedSubscription):
                return feedSubscription.view
            case .list(let listSubscription):
                return listSubscription.view
            case .inbox(let inboxSubscription):
                return inboxSubscription.view
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
        public let userId: String?
        public let view: Int?
        public let feedId: String?
        public let lists: List?
        public let isPrivate: Bool?
        public let listId: String?
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

    public struct List: Codable, Sendable {
        public let type: String?
        public let id: String?
        public let view: Int?
        public let feedIds: [String]?
        public let fee: Int?
        public let timelineUpdatedAt: String?
        public let description: String?
        public let title: String?
        public let image: String?
        public let ownerUserId: String?
        public let owner: User?
        
        public var imageUrl: String? {
            if let image {
                return image
            }
            return nil
        }
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
        public let id: String?
        public let emailVerified: Bool?
        public let image: String?
        public let handle: String?
        public let createdAt: String?
    }
}

// MARK: - Network Request

public enum SingleOrArray<T: Sendable>: Sendable {
    case single(T)
    case array([T])
}

// MARK: - Network Request

public actor SubscriptionService {
    public init() {}
    
    public func getSubscriptions(userId: SingleOrArray<String>? = nil, view: SingleOrArray<String>? = nil) async throws -> Subscriptions.Response {
        var urlComponents = URLComponents(url: NetworkManager.baseURL.appendingPathComponent("subscriptions"), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = []
        
        if let userId = userId {
            switch userId {
            case .single(let t):
                urlComponents?.queryItems?.append(URLQueryItem(name: "userId", value: t))
            case .array(let array):
                urlComponents?.queryItems?.append(contentsOf: array.map { URLQueryItem(name: "userId", value: $0)})
            }
        }
        
        if let view = view {
            switch view {
            case .single(let t):
                urlComponents?.queryItems?.append(URLQueryItem(name: "view", value: t))
            case .array(let array):
                urlComponents?.queryItems?.append(contentsOf: array.map { URLQueryItem(name: "view", value: $0)})
            }
        }
        
        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await NetworkManager.shared.request(url)
    }
}

// Usage example:
// let service = SubscriptionService()
//
// Task {
//     do {
//         let response = try await service.getSubscriptions(userId: .single("user123"), view: .array(["1", "2"]))
//         print(response)
//     } catch {
//         print("Error: \(error)")
//     }
// }
