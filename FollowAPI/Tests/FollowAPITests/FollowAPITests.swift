@testable import FollowAPI
import Foundation
import Testing

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let baseURL = URL(string: "https://api.follow.is")!
    let service = SubscriptionService(baseURL: baseURL)

    do {
        let response = try await service.getSubscriptions()
        print(response)
    } catch {
        print("Error: \(error)")
    }
}
