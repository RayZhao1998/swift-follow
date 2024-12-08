//
//  ProfileView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/11/2.
//

import BigInt
import FollowAPI
import Kingfisher
import SwiftUI

func formatBigInt(_ value: BigInt, precision: Int, trailingZeros: Bool) -> String {
    let divisor = BigInt(10).power(precision)
    let decimalValue = Decimal(string: "\(value)")! / Decimal(string: "\(divisor)")!

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    formatter.roundingMode = .halfUp

    return formatter.string(from: decimalValue as NSNumber) ?? "\(decimalValue)"
}

struct ProfileView: View {
    @Environment(\.sessionData) var sessionData: Auth.SessionResponse?

    @EnvironmentObject private var authHandler: AuthenticationHandler

    let walletService = WalletsService()

    @State private var wallet: Wallets.Wallet?

    var formattedFullPower: String {
        guard let power = BigInt(wallet?.powerToken ?? "0") else {
            return "0"
        }
        return formatBigInt(power, precision: 18, trailingZeros: true)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    VStack {
                        HStack {
                            if let avatar = sessionData?.user.image,
                               let avatarUrl = URL(string: avatar)
                            {
                                KFImage.url(avatarUrl)
                                    .resizable()
                                    .roundCorner(
                                        radius: .widthFraction(1),
                                        roundingCorners: .all)
                                    .loadDiskFileSynchronously()
                                    .cacheMemoryOnly()
                                    .frame(width: 48, height: 48)
                            }
                            VStack(alignment: .leading) {
                                Text(sessionData?.user.name ?? "")
                                    .font(.custom("SNProVF-Bold", size: 20))
                                    .bold()
                                HStack(spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image("power")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundStyle(Color(red: 255 / 255, green: 92 / 255, blue: 0))
                                            .frame(width: 14, height: 14)
                                        Text("\(formattedFullPower)")
                                            .font(.custom("SNProVF-Medium", size: 14))
                                    }
                                    if let level = wallet?.level?.level {
                                        HStack(spacing: 4) {
                                            Image("vip")
                                                .resizable()
                                                .renderingMode(.template)
                                                .foregroundStyle(
                                                    Color(red: 255 / 255, green: 92 / 255, blue: 0))
                                                .frame(width: 14, height: 14)
                                            Text("Lv.\(level)")
                                                .font(.custom("SNProVF-Medium", size: 14))
                                        }
                                    }
                                    if let prevActivityPoints = wallet?.level?.prevActivityPoints {
                                        HStack(spacing: 4) {
                                            Image("fire")
                                                .resizable()
                                                .renderingMode(.template)
                                                .foregroundStyle(
                                                    Color(red: 255 / 255, green: 92 / 255, blue: 0))
                                                .frame(width: 14, height: 14)
                                            Text("\(prevActivityPoints)")
                                                .font(.custom("SNProVF-Medium", size: 14))
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.systemGroupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Image("person")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 16, height: 16)
                            Text("Profile")
                                .font(.custom("SNProVF-Medium", size: 16))
                        }
                        .padding()
                        Divider()
                        HStack {
                            Image("trophy")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 16, height: 16)
                            Text("Achievements")
                                .font(.custom("SNProVF-Medium", size: 16))
                        }
                        .padding()
                        Divider()
                        HStack {
                            Image("gear")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 16, height: 16)
                            Text("Preferences")
                                .font(.custom("SNProVF-Medium", size: 16))
                        }
                        .padding()
                    }
                    .foregroundStyle(Color.label)
                    .background(Color.systemGroupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    Button(action: {
                        authHandler.logout()
                    }) {
                        HStack {
                            Spacer()
                            Image("logout")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Log out")
                                .bold()
                            Spacer()
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .background(Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .font(.custom("SNProVF-Medium", size: 14))
            .onAppear {
                Task {
                    self.wallet = try? await walletService.getWallets().data.first
                }
            }
        }
    }
}
