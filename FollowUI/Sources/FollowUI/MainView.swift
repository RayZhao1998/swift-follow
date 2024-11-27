//
//  MainView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/17.
//

import FollowAPI
import Kingfisher
import SwiftUI

struct MainView: View {
    var body: some View {
        
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            TabView {
                Tab("Reader", systemImage: "richtext.page.fill") {
                    EntryListView()
                }
                Tab("Subscriptions", systemImage: "mail.stack") {
                    SubscriptionListView()
                }
                Tab("Profile", systemImage: "person.fill") {
                    ProfileView()
                }
            }
        } else {
            TabView {
                EntryListView()
                    .tabItem {
                        Label("Reader", systemImage: "richtext.page.fill")
                    }
                SubscriptionListView()
                    .tabItem {
                        Label("Subscriptions", systemImage: "mail.stack")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
        }
    }
}

#Preview {
    MainView()
}
