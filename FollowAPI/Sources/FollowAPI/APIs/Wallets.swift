import Alamofire
import Foundation

public enum Wallets {
    // MARK: - Response Structures
    public struct GetWalletsResponse: Codable, Sendable {
        public let code: Int
        public let data: [Wallet]
    }

    public struct Wallet: Codable, Sendable {
        public let createdAt: String
        public let userId: String
        public let addressIndex: Int
        public let address: String?
        public let powerToken: String
        public let dailyPowerToken: String
        public let cashablePowerToken: String
        public let level: Level?
        public let todayDailyPower: String
    }

    public struct Level: Codable, Sendable {
        public let rank: Int?
        public let level: Int?
        public let prevActivityPoints: Int?
        public let activityPoints: Int?
    }

    public struct PostWalletsResponse: Codable, Sendable {
        public let code: Int
        public let data: String
    }
}

public actor WalletsService {
    public init() {}

    public func getWallets() async throws -> Wallets.GetWalletsResponse {
        let url = NetworkManager.baseURL.appendingPathComponent("wallets")
        return try await NetworkManager.shared.request(url, method: .get)
    }
}
