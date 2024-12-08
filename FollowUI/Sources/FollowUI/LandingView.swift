//
//  LandingView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/18.
//

import AuthenticationServices
import Awesome
import FollowAPI
import Kingfisher
import SwiftUI

struct SessionDataKey: EnvironmentKey {
    static let defaultValue: Auth.SessionResponse? = nil
}

extension EnvironmentValues {
    var sessionData: Auth.SessionResponse? {
        get { self[SessionDataKey.self] }
        set { self[SessionDataKey.self] = newValue }
    }
}

class AuthenticationHandler: NSObject, ObservableObject, @unchecked Sendable {
    @Published var isAuthenticated: Bool? = false
    @Published var sessionData: Auth.SessionResponse?

    private var webAuthSession: ASWebAuthenticationSession?
    private let authService = AuthService()

    override init() {
        super.init()
        Task {
            await loadSessionData()
        }
    }

    func startAuthentication(_ type: String) {
        guard let url = URL(string: "https://app.follow.is/login?provider=\(type)") else { return }

        webAuthSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "follow") {
            callbackURL, error in
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
              let queryItems = components.queryItems
        else { return }

        if let token = queryItems.first(where: { $0.name == "token" })?.value {
            Task {
                await self.setSessionToken(token)
            }
        }
    }

    public func setSessionToken(_ token: String) async {
        NetworkManager.shared.setSessionToken(token)
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
        do {
            let session = try await authService.getSession(authToken: token)
            await MainActor.run {
                self.isAuthenticated = true
            }
            saveSessionData(sessionData: session)
        } catch {
            print("认证会话失败: \(error.localizedDescription)")
        }
    }

    private func saveSessionData(sessionData: Auth.SessionResponse?) {
        guard let sessionData = sessionData else { return }
        self.sessionData = sessionData
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
        if let sessionData = KeychainWrapper.load(forKey: "sessionData") {
            self.sessionData = try? JSONDecoder().decode(
                Auth.SessionResponse.self, from: sessionData
            )
        }
        if let sessionTokenData = KeychainWrapper.load(forKey: "sessionToken") {
            do {
                let sessionToken: String = try JSONDecoder().decode(
                    String.self, from: sessionTokenData
                )
                NetworkManager.shared.setSessionToken(sessionToken)
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
        _ = KeychainWrapper.delete(forKey: "sessionData")
        _ = KeychainWrapper.delete(forKey: "sessionToken")
        NetworkManager.shared.clearTokens()
    }
}

extension AuthenticationHandler: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

extension Color {
    static let redGradientStart = Color(
        light: .init(red: 252 / 255, green: 165 / 255, blue: 165 / 255), // red-300
        dark: .init(red: 239 / 255, green: 68 / 255, blue: 68 / 255)
    ) // red-500
    static let orangeGradientEnd = Color(
        light: .init(red: 253 / 255, green: 186 / 255, blue: 116 / 255), // orange-300
        dark: .init(red: 249 / 255, green: 115 / 255, blue: 22 / 255)
    ) // orange-500
}

struct LandingView: View {
    @StateObject private var authHandler = AuthenticationHandler()
    @State private var showMainView = false
    @State private var logoOffset: CGFloat = 50
    @State private var logoOpacity: CGFloat = 0
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: CGFloat = 0
    @State private var subtitleOffset: CGFloat = 50
    @State private var subtitleOpacity: CGFloat = 0
    @State private var buttonsOffset: CGFloat = 50
    @State private var buttonsOpacity: CGFloat = 0
    @State private var animateGradient: Bool = false

    @State private var showDemoModeLoginView: Bool = false

    var body: some View {
        Group {
            if showMainView {
                MainView()
                    .environment(\.sessionData, authHandler.sessionData)
                    .environmentObject(authHandler)
            } else {
                contentView
            }
        }
        .onChange(of: authHandler.isAuthenticated, initial: true) { _, newValue in
            if let newValue {
                DispatchQueue.main.async {
                    self.showMainView = newValue
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if let isAuthenticated = authHandler.isAuthenticated {
            VStack {
                Spacer()
                HStack {
                    Image("FollowIcon")
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text("Follow")
                        .font(.custom("SNProVF-Bold", size: 28))
                }
                .offset(y: logoOffset)
                Spacer()
                    .frame(height: 20)
                HStack(spacing: 0) {
                    Text("Next-Gen")
                        .background(
                            LinearGradient(
                                colors: [
                                    .redGradientStart,
                                    .orangeGradientEnd,
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .cornerRadius(8)
                            .scaleEffect(x: animateGradient ? 1 : 0, y: 1, anchor: .leading)
                            .animation(.snappy(duration: 0.25).delay(0.6), value: animateGradient)
                        )
                        .onAppear {
                            animateGradient = true
                        }
                    Text(" Information Browser")
                }
                .font(.custom("SNProVF-Bold", size: 20))
                .offset(y: titleOffset)
                .opacity(titleOpacity)

                Spacer()
                if isAuthenticated {
                    Text("Redirecting...")
                        .offset(y: buttonsOffset)
                        .opacity(buttonsOpacity)
                } else {
                    VStack(spacing: 10) {
                        Button {
                            self.showDemoModeLoginView.toggle()
                        } label: {
                            Text("No account? Demo mode >")
                        }
                        .buttonStyle(.plain)
                        .sheet(isPresented: $showDemoModeLoginView) {
                            DemoModeLoginView()
                                .environmentObject(authHandler)
                        }
                        Button(action: {
                            authHandler.startAuthentication("github")
                        }) {
                            HStack {
                                Spacer()
                                Awesome.Brand.github.image
                                    .foregroundColor(.white)
                                Text("Continue with Github")
                                    .bold()
                                Spacer()
                            }
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        Button(action: {
                            authHandler.startAuthentication("google")
                        }) {
                            HStack {
                                Spacer()
                                Awesome.Brand.google.image
                                    .foregroundColor(.white)
                                Text("Continue with Google")
                                    .bold()
                                Spacer()
                            }
                            .padding()
                            .background(Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                    .offset(y: buttonsOffset)
                    .opacity(buttonsOpacity)
                }
            }
            .padding()
            .onAppear {
                withAnimation(.snappy(duration: 0.5).delay(0.0)) {
                    logoOffset = 0
                    logoOpacity = 1
                }

                withAnimation(.snappy(duration: 0.5).delay(0.2)) {
                    titleOffset = 0
                    titleOpacity = 1
                }

                withAnimation(.snappy(duration: 0.5).delay(0.4)) {
                    subtitleOffset = 0
                    subtitleOpacity = 1
                }

                withAnimation(.snappy(duration: 0.5).delay(0.6)) {
                    buttonsOffset = 0
                    buttonsOpacity = 1
                }
            }
        } else {
            ProgressView()
        }
    }
}

#Preview {
    LandingView()
}
