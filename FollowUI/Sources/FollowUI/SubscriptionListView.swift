//
//  SubscriptionListView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/15.
//

import Awesome
import FollowAPI
import Kingfisher
import SwiftUI

struct ViewDefination: Equatable {
    let name: String
    let iconName: String
    let view: Int
    let selectedColor: Color
}

let views: [ViewDefination] = [
    ViewDefination(
        name: "Articles", iconName: "paper", view: 0,
        selectedColor: Color(red: 255 / 255, green: 92 / 255, blue: 0)),
    ViewDefination(
        name: "Social Media", iconName: "twitter", view: 1,
        selectedColor: Color(red: 14 / 255, green: 165 / 255, blue: 233 / 255)),
    ViewDefination(
        name: "Pictures", iconName: "pic", view: 2,
        selectedColor: Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255)),
    ViewDefination(
        name: "Videos", iconName: "video", view: 3,
        selectedColor: Color(red: 239 / 255, green: 68 / 255, blue: 68 / 255)),
    ViewDefination(
        name: "Audios", iconName: "mic", view: 4,
        selectedColor: Color(red: 168 / 255, green: 85 / 255, blue: 247 / 255)),
    ViewDefination(
        name: "Notifications", iconName: "announcement", view: 5,
        selectedColor: Color(red: 234 / 255, green: 179 / 255, blue: 8 / 255)),
]

public struct SubscriptionListView: View {
    @State private var subscriptions: [Int: [Subscriptions.Subscription]] = [:]

    @State private var reads: [String: Int] = [:]

    @State private var selectedView: ViewDefination = views.first!

    @State private var isLoading: Bool = true

    let subscriptionService = SubscriptionService()

    let readsService = ReadsService()

    public init() {}

    var listSubscriptions: [Subscriptions.ListSubscription] {
        var result: [Subscriptions.ListSubscription] = []
        for subscription in subscriptions[selectedView.view] ?? [] {
            if case .list(let listSubscription) = subscription {
                result.append(listSubscription)
            }
        }
        return result
    }

    var inboxSubscriptions: [Subscriptions.InboxSubscription] {
        var result: [Subscriptions.InboxSubscription] = []
        for subscription in subscriptions[selectedView.view] ?? [] {
            if case .inbox(let inboxSubscription) = subscription {
                result.append(inboxSubscription)
            }
        }
        return result
    }

    var feedSubscriptions: [Subscriptions.FeedSubscription] {
        var result: [Subscriptions.FeedSubscription] = []
        for subscription in subscriptions[selectedView.view] ?? [] {
            if case .feed(let feedSubscription) = subscription {
                result.append(feedSubscription)
            }
        }
        return result
    }

    private func unreadCount(_ view: Int) -> Int {
        subscriptions[view]?.reduce(0) { result, subscription in
            result + (reads[subscription.id] ?? 0)
        } ?? 0
    }

    public var body: some View {
        NavigationStack {
            VStack {
                HStack(alignment: .bottom, spacing: 12) {
                    Text(selectedView.name)
                        .font(.custom("SNProVF-Bold", size: 20))
                        .bold()
                        .lineLimit(1)
                    Spacer()
                    ForEach(views, id: \.name) { item in
                        VStack(spacing: 4) {
                            Image(item.iconName)
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 20, height: 20)
                            Text("\(unreadCount(item.view) > 99 ? "99+" : "\(unreadCount(item.view))")")
                                .font(.custom("SNProVF-Regular", size: 10))
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
                } else if (subscriptions[selectedView.view] ?? []).isEmpty {
                    VStack {
                        Spacer()
                        Group {
                            Image("emptybox")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 32, height: 32)
                            Text("Zero items")
                        }
                        // rgb(161, 161, 170)
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 170 / 255))
                        Spacer()
                    }
                } else {
                    List {
                        if !listSubscriptions.isEmpty {
                            Section("Lists") {
                                ForEach(listSubscriptions, id: \.listId) { subscription in
                                    NavigationLink {
                                        EntryListView(lists: subscription.lists)
                                    } label: {
                                        HStack {
                                            if let image = subscription.lists.image,
                                               let imageUrl = URL(string: image)
                                            {
                                                KFImage.url(imageUrl)
                                                    .resizable()
                                                    .roundCorner(
                                                        radius: .widthFraction(0.2),
                                                        roundingCorners: .all)
                                                    .loadDiskFileSynchronously()
                                                    .cacheMemoryOnly()
                                                    .frame(width: 28, height: 28)
                                            }
                                            Text(subscription.lists.title ?? "")
                                                .lineLimit(1)
                                            Spacer()
                                            if let count = reads[subscription.listId] {
                                                Text("\(count)")
                                                    .font(.custom("SNProVF-Regular", size: 10))
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if !inboxSubscriptions.isEmpty {
                            Section("Inboxes") {
                                ForEach(inboxSubscriptions, id: \.inboxId) { subscription in
                                    HStack {
                                        if let image = subscription.inboxes.image,
                                           let imageUrl = URL(string: image)
                                        {
                                            KFImage.url(imageUrl)
                                                .resizable()
                                                .roundCorner(
                                                    radius: .widthFraction(0.2),
                                                    roundingCorners: .all)
                                                .loadDiskFileSynchronously()
                                                .cacheMemoryOnly()
                                                .frame(width: 28, height: 28)
                                        }
                                        Text(subscription.title ?? "")
                                            .lineLimit(1)
                                        Spacer()
                                        if let count = reads[subscription.inboxId] {
                                            Text("\(count)")
                                                .font(.custom("SNProVF-Regular", size: 10))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        if !feedSubscriptions.isEmpty {
                            Section("Feeds") {
                                ForEach(feedSubscriptions, id: \.feedId) { subscription in
                                    NavigationLink {
                                        EntryListView(feeds: subscription.feeds)
                                    } label: {
                                        HStack {
                                            if let image = subscription.feeds.image,
                                               let imageUrl = URL(string: image)
                                            {
                                                KFImage.url(imageUrl)
                                                    .resizable()
                                                    .roundCorner(
                                                        radius: .widthFraction(0.2),
                                                        roundingCorners: .all)
                                                    .loadDiskFileSynchronously()
                                                    .cacheMemoryOnly()
                                                    .frame(width: 28, height: 28)
                                            }
                                            Text(subscription.feeds.title ?? "")
                                                .lineLimit(1)
                                            Spacer()
                                            if let count = reads[subscription.feedId] {
                                                Text("\(count)")
                                                    .font(.custom("SNProVF-Regular", size: 10))
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .refreshable {
                        await fetchSubscriptions()
                    }
                }
            }
        }
        .font(.custom("SNProVF-Regular", size: 16))
        .onAppear {
            withAnimation {
                self.isLoading = true
            } completion: {
                Task {
                    await fetchSubscriptions(firstTime: true)
                    withAnimation {
                        self.isLoading = false
                    }
                }
            }
        }
        .onChange(of: selectedView) { _, _ in
            withAnimation {
                self.isLoading = true
            } completion: {
                Task {
                    await fetchSubscriptions()
                    withAnimation {
                        self.isLoading = false
                    }
                }
            }
        }
    }

    private func fetchSubscriptions(firstTime: Bool = false) async {
        do {
            let result = try await subscriptionService.getSubscriptions(
                view: firstTime ? nil : .single("\(selectedView.view)")
            ).data
            if firstTime {
                subscriptions = [:]
                for subscription in result {
                    subscriptions[subscription.view, default: []].append(subscription)
                }
            } else {
                subscriptions[selectedView.view] = result
            }
            reads = try await readsService.getReads()
                .data
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

#Preview {
    SubscriptionListView()
}
