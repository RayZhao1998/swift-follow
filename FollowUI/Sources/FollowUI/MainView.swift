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
    }
}

#Preview {
    MainView()
}
