import Alamofire
import Foundation

public final class NetworkManager: @unchecked Sendable {
    static let baseURL = URL(string: "https://api.follow.is")!
    public static let shared = NetworkManager()
    
    private var sessionToken: String?
    
    private init() {}
    
    public func setBetterAuthSessionToken(_ ck: String) {
        sessionToken = ck
    }
    
    public func clearTokens() {
        sessionToken = nil
    }
    
    public func request<T: Decodable & Sendable>(_ url: URLConvertible,
                                                 method: HTTPMethod = .get,
                                                 parameters: Parameters? = nil,
                                                 encoding: ParameterEncoding = URLEncoding.default,
                                                 headers: HTTPHeaders? = nil) async throws -> T
    {
        guard let sessionToken = sessionToken else {
            throw AFError.sessionTaskFailed(error: NSError(domain: "NetworkManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No session token available"]))
        }
        
        var finalHeaders = headers ?? HTTPHeaders()
        guard let components = atob(sessionToken)?.split(separator: "="), components.count == 2 else {
            throw AFError.sessionTaskFailed(error: NSError(domain: "NetworkManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid session token"]))
        }
        
        finalHeaders.add(name: "Cookie", value: "\(String(components[0]))=\(String(components[1]));")
        
        return try await AF.request(url,
                                    method: method,
                                    parameters: parameters,
                                    encoding: encoding,
                                    headers: finalHeaders)
            .validate()
            .serializingDecodable(T.self)
            .value
    }
    
    // This method is used to decode the base64 encoded string
    private func atob(_ base64String: String) -> String? {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
