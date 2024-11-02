//
//  Auth.swift
//  FollowAPI
//
//  Created by ZiyuanZhao on 2024/10/19.
//

import Foundation

public enum Auth {
    public struct SessionResponse: Codable, Sendable {
        public let userId: String
        public let expires: String
        public let user: User
        public let invitation: Invitation?

        public struct User: Codable, Sendable {
            public let id: String
            public let name: String
            public let email: String
            public let emailVerified: String?
            public let image: String?
            public let handle: String?
            public let createdAt: String
        }

        public struct Invitation: Codable, Sendable {
            public let code: String
            public let createdAt: String
            public let fromUserId: String
            public let toUserId: String
        }
    }

    public struct CSRFTokenResponse: Codable, Sendable {
        public let csrfToken: String
    }
}

public actor AuthService {
    public init() {}

    public func getSession(authToken: String) async throws -> Auth.SessionResponse {
        let urlComponents = URLComponents(url: NetworkManager.baseURL.appendingPathComponent("auth/session"), resolvingAgainstBaseURL: false)

        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await NetworkManager.shared.request(url)
    }
    
    public func getCsrfToken() async throws -> Auth.CSRFTokenResponse {
        let urlComponents = URLComponents(url: NetworkManager.baseURL.appendingPathComponent("auth/csrf"), resolvingAgainstBaseURL: false)

        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await NetworkManager.shared.request(url)
    }
}
