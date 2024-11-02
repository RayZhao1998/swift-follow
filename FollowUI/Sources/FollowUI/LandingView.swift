//
//  LandingView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/18.
//

import AuthenticationServices
import FollowAPI
import Kingfisher
import SwiftUI

class AuthenticationHandler: NSObject, ObservableObject, @unchecked Sendable {
    @Published var isAuthenticated: Bool? = false

    private var webAuthSession: ASWebAuthenticationSession?
    private let authService = AuthService()

    override init() {
        super.init()
        Task {
            await loadSessionData()
        }
    }

    func startAuthentication() {
        guard let url = URL(string: "https://app.follow.is/login?provider=github") else { return }

        webAuthSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "follow") { callbackURL, error in
            guard error == nil, let successURL = callbackURL else {
                print("Authentication failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.handleCallback(url: successURL)
        }

        webAuthSession?.presentationContextProvider = self
        webAuthSession?.prefersEphemeralWebBrowserSession = true
        webAuthSession?.start()
    }

    private func handleCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return }

        if let token = queryItems.first(where: { $0.name == "token" })?.value {
            Task {
                do {
                    NetworkManager.shared.setSessionToken(token)
                    self.setSessionToken(token)
                    let session = try await authService.getSession(authToken: token)
                    let csrfToken = try await authService.getCsrfToken().csrfToken
                    NetworkManager.shared.setCSRToken(csrfToken)
                    await MainActor.run {
                        self.isAuthenticated = true
                    }
                    self.saveSessionData(sessionData: session)
                } catch {
                    print("认证会话失败: \(error.localizedDescription)")
                    // 可以在这里添加错误处理逻辑
                }
            }
        }
    }
    
    private func setSessionToken(_ token: String) {
        do {
            let data = try JSONEncoder().encode(token)
            if KeychainWrapper.save(data, forKey: "sessionToken") {
                print("Session token saved successfully")
            } else {
                print("Failed to save session token")
            }
        } catch {
            print("Error encoding session data: \(error)")
        }
    }

    private func saveSessionData(sessionData: Auth.SessionResponse?) {
        guard let sessionData = sessionData else { return }
        do {
            let data = try JSONEncoder().encode(sessionData)
            if KeychainWrapper.save(data, forKey: "sessionData") {
                print("Session data saved successfully")
            } else {
                print("Failed to save session data")
            }
        } catch {
            print("Error encoding session data: \(error)")
        }
    }

    private func loadSessionData() async {
        if let sessionTokenData = KeychainWrapper.load(forKey: "sessionToken") {
            do {
                let sessionToken: String = try JSONDecoder().decode(String.self, from: sessionTokenData)
                NetworkManager.shared.setSessionToken(sessionToken)
                let csrfToken = try await authService.getCsrfToken().csrfToken
                NetworkManager.shared.setCSRToken(csrfToken)
                isAuthenticated = true
            } catch {
                isAuthenticated = false
            }
        } else {
            isAuthenticated = false
        }
    }

    func logout() {
        isAuthenticated = false
        KeychainWrapper.delete(forKey: "sessionData")
        KeychainWrapper.delete(forKey: "sessionToken")
        NetworkManager.shared.clearTokens()
    }
}

extension AuthenticationHandler: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

struct LandingView: View {
    @StateObject private var authHandler = AuthenticationHandler()
    @State private var showMainView = false

    var body: some View {
        Group {
            if showMainView {
                MainView()
            } else {
                contentView
            }
        }
        .onChange(of: authHandler.isAuthenticated) { newValue in
            if newValue == true {
                DispatchQueue.main.async {
                    self.showMainView = true
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if let isAuthenticated = authHandler.isAuthenticated {
            VStack {
                KFImage.url(URL(string: "https://github.com/RSSNext/follow/assets/41265413/c6c02ad5-cddc-46f5-8420-a47afe1c82fe")!)
                    .resizable()
                    .frame(width: 80, height: 80)

                if isAuthenticated {
                    Text("Redirecting...")
                } else {
                    Button(action: {
                        Task {
                            await authHandler.startAuthentication()
                        }
                    }) {
                        Text("Continue with Github")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        } else {
            ProgressView()
        }
    }
}

#Preview {
    LandingView()
}
