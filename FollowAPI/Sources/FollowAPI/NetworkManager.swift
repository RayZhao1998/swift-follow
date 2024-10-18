import Foundation
import Alamofire

public final class NetworkManager: @unchecked Sendable {
    static let baseURL = URL(string: "https://api.follow.is")!
    public static let shared = NetworkManager()
    
    private let queue = DispatchQueue(label: "is.follow.app.NetworkManager")
    private var sessionToken: String?
    public var csrfToken: String?
    
    private init() {}
    
    public func setSessionToken(_ token: String) {
        queue.async {
            self.sessionToken = token
        }
    }
    
    public func setCSRToken(_ token: String) {
        queue.async {
            self.csrfToken = token
        }
    }
    
    public func clearTokens() {
        queue.async {
            self.sessionToken = nil
            self.csrfToken = nil
        }
    }
    
    private func getCsrfToken() async throws -> String {
        if let csrfToken = self.csrfToken {
            return csrfToken
        }
        
        let authService = AuthService()
        let response = try await authService.getCsrfToken()
        self.csrfToken = response.csrfToken
        return response.csrfToken
    }
    
    public func request<T: Decodable & Sendable>(_ url: URLConvertible,
                                      method: HTTPMethod = .get,
                                      parameters: Parameters? = nil,
                                      encoding: ParameterEncoding = URLEncoding.default,
                                      headers: HTTPHeaders? = nil) async throws -> T {
        guard let sessionToken = self.sessionToken else {
            throw AFError.sessionTaskFailed(error: NSError(domain: "NetworkManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No session token available"]))
        }
        
        var finalHeaders = headers ?? HTTPHeaders()
        finalHeaders.add(name: "Cookie", value: "authjs.session-token=\(sessionToken); authjs.csrf-token=\(csrfToken)")
        
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
