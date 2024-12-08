//
//  DemoModeLoginView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/11/4.
//

import SwiftUI

struct DemoModeLoginView: View {
    @State private var sessionToken = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var authHandler: AuthenticationHandler

    var body: some View {
        Form {
            TextField("Session Token", text: $sessionToken)
            Button {
                dismiss()
                Task {
                    await authHandler.setBetterAuthSessionToken(sessionToken)
                }
            } label: {
                Text("Login")
            }
        }
    }
}
