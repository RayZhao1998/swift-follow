import Alamofire
import Foundation

public struct CSRFTokenResponse: Codable, Sendable {
    public let csrfToken: String
}

public final class NetworkManager: @unchecked Sendable {
    static let baseURL = URL(string: "https://api.follow.is")!
    public static let shared = NetworkManager()
    
    private var sessionToken: String?
    public var csrfToken: String?
    
    private init() {}
    
    public func setSessionToken(_ token: String) {
        sessionToken = token
    }
    
    public func setCSRToken(_ token: String) {
        csrfToken = token
    }
    
    public func clearTokens() {
        sessionToken = nil
        csrfToken = nil
    }
    
    private func requestWithoutCsrf<T: Decodable & Sendable>(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        guard let sessionToken = sessionToken else {
            throw AFError.sessionTaskFailed(error: NSError(domain: "NetworkManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No session token available"]))
        }
        
        var finalHeaders = headers ?? HTTPHeaders()
        finalHeaders.add(name: "Cookie", value: "authjs.session-token=\(sessionToken); authjs.csrf-token=\(csrfToken ?? "")")
        finalHeaders.add(name: "X-CSRF-Token", value: csrfToken ?? "")
        
        return try await AF.request(url,
                                    method: method,
                                    parameters: parameters,
                                    encoding: encoding,
                                    headers: finalHeaders)
            .validate()
            .serializingDecodable(T.self)
            .value
    }
    
    private func getCsrfToken() async throws -> String {
        let response: CSRFTokenResponse = try await requestWithoutCsrf(
            NetworkManager.baseURL.appendingPathComponent("auth/csrf")
        )
        csrfToken = response.csrfToken
        return response.csrfToken
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
        let csrfToken = (try? await getCsrfToken()) ?? ""
        finalHeaders.add(name: "Cookie", value: "authjs.session-token=\(sessionToken); authjs.csrf-token=\(csrfToken)")
        finalHeaders.add(name: "X-CSRF-Token", value: csrfToken)
        
        return try await AF.request(url,
                                    method: method,
                                    parameters: parameters,
                                    encoding: encoding,
                                    headers: finalHeaders)
            .validate()
            .serializingDecodable(T.self)
            .value
    }
}
