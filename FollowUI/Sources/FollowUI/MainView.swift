//
//  MainView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/17.
//

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
        }
    }
}

#Preview {
    MainView()
}
