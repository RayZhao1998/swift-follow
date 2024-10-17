//
//  SubscriptionListView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/15.
//

import FollowAPI
import Kingfisher
import SwiftUI

struct ViewDefination: Equatable {
    let name: String
    let icon: String
    let view: String
    let selectedColor: Color
}

let views: [ViewDefination] = [
    ViewDefination(name: "Articles", icon: "text.page.fill", view: "0", selectedColor: Color(red: 255/255, green: 92/255, blue: 0)),
    ViewDefination(name: "Social Media", icon: "bird.fill", view: "1", selectedColor: Color(red: 14/255, green: 165/255, blue: 233/255)),
    ViewDefination(name: "Pictures", icon: "photo.fill", view: "2", selectedColor: Color(red: 34/255, green: 197/255, blue: 94/255)),
    ViewDefination(name: "Videos", icon: "video.fill", view: "3", selectedColor: Color(red: 239/255, green: 68/255, blue: 68/255)),
    ViewDefination(name: "Audios", icon: "microphone.fill", view: "4", selectedColor: Color(red: 168/255, green: 85/255, blue: 247/255)),
    ViewDefination(name: "Notifications", icon: "app.badge.fill", view: "5", selectedColor: Color(red: 234/255, green: 179/255, blue: 8/255)),
]

public struct SubscriptionListView: View {
    @State private var subscriptions: [Subscriptions.Subscription] = []

    @State private var selectedView: ViewDefination = views.first!

    @State private var isLoading: Bool = true

    let service = SubscriptionService()

    public init() {}

    var listSubscriptions: [Subscriptions.ListSubscription] {
        var result: [Subscriptions.ListSubscription] = []
        for subscription in subscriptions {
            if case .list(let listSubscription) = subscription {
                result.append(listSubscription)
            }
        }
        return result
    }

    var inboxSubscriptions: [Subscriptions.InboxSubscription] {
        var result: [Subscriptions.InboxSubscription] = []
        for subscription in subscriptions {
            if case .inbox(let inboxSubscription) = subscription {
                result.append(inboxSubscription)
            }
        }
        return result
    }

    var feedSubscriptions: [Subscriptions.FeedSubscription] {
        var result: [Subscriptions.FeedSubscription] = []
        for subscription in subscriptions {
            if case .feed(let feedSubscription) = subscription {
                result.append(feedSubscription)
            }
        }
        return result
    }

    public var body: some View {
        NavigationStack {
            VStack {
                HStack(alignment: .bottom, spacing: 12) {
                    Text(selectedView.name)
                        .font(.title2)
                        .bold()
                        .lineLimit(1)
                    Spacer()
                    ForEach(views, id: \.name) { item in
                        VStack(spacing: 4) {
                            Image(systemName: item.icon)
                                .frame(width: 20, height: 20)
                            Text("99+")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(item == selectedView ? item.selectedColor : .secondary)
                        .onTapGesture {
                            withAnimation {
                                self.selectedView = item
                            }
                        }
                    }
                }
                .padding(.horizontal)
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    List {
                        if !listSubscriptions.isEmpty {
                            Section("Lists") {
                                ForEach(listSubscriptions, id: \.listId) { subscription in
                                    NavigationLink {
                                        EntryListView(listId: subscription.listId)
                                    } label: {
                                        HStack {
                                            if let image = subscription.lists.image, let imageUrl = URL(string: image) {
                                                KFImage.url(imageUrl)
                                                    .resizable()
                                                    .roundCorner(radius: .widthFraction(0.2), roundingCorners: .all)
                                                    .loadDiskFileSynchronously()
                                                    .cacheMemoryOnly()
                                                    .frame(width: 28, height: 28)
                                            }
                                            Text(subscription.lists.title ?? "")
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                        }
                        if !inboxSubscriptions.isEmpty {
                            Section("Inboxes") {
                                ForEach(inboxSubscriptions, id: \.inboxId) { subscription in
                                    HStack {
                                        if let image = subscription.inboxes.image, let imageUrl = URL(string: image) {
                                            KFImage.url(imageUrl)
                                                .resizable()
                                                .roundCorner(radius: .widthFraction(0.2), roundingCorners: .all)
                                                .loadDiskFileSynchronously()
                                                .cacheMemoryOnly()
                                                .frame(width: 28, height: 28)
                                        }
                                        Text(subscription.title ?? "")
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        if !feedSubscriptions.isEmpty {
                            Section("Feeds") {
                                ForEach(feedSubscriptions, id: \.feedId) { subscription in
                                    NavigationLink {
                                        EntryListView(feedId: subscription.feedId)
                                    } label: {
                                        HStack {
                                            if let image = subscription.feeds.image, let imageUrl = URL(string: image) {
                                                KFImage.url(imageUrl)
                                                    .resizable()
                                                    .roundCorner(radius: .widthFraction(0.2), roundingCorners: .all)
                                                    .loadDiskFileSynchronously()
                                                    .cacheMemoryOnly()
                                                    .frame(width: 28, height: 28)
                                            }
                                            Text(subscription.feeds.title ?? "")
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchSubscriptions()
        }
        .onChange(of: selectedView) { _, _ in
            fetchSubscriptions()
        }
    }

    private func fetchSubscriptions() {
        withAnimation {
            self.isLoading = true
        } completion: {
            Task {
                do {
                    let result = try await service.getSubscriptions(view: .single(selectedView.view)).data
                    self.subscriptions = result
                    withAnimation {
                        self.isLoading = false
                    }
                } catch {
                    withAnimation {
                        self.isLoading = false
                    }
                    print("Error: \(error)")
                }
            }
        }
    }
}

#Preview {
    SubscriptionListView()
}
