//
//  SubscriptionListView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/15.
//

import FollowAPI
import Kingfisher
import SwiftUI

public struct SubscriptionListView: View {
    @State private var subscriptions: [Subscription] = []

    public init() {}

    public var body: some View {
        List {
            ForEach(subscriptions) { subscription in
                switch subscription {
                case .feed(let feedSubscription):
                    HStack {
                        if let image = feedSubscription.feeds.image, let imageUrl = URL(string: image) {
                            KFImage.url(imageUrl)
                                .resizable()
                                .roundCorner(radius: .widthFraction(0.2), roundingCorners: .all)
                                .loadDiskFileSynchronously()
                                .cacheMemoryOnly()
                                .frame(width: 28, height: 28)
                        }
                        Text(feedSubscription.feeds.title ?? "")
                    }
                case .list(let listSubscription):
                    HStack {
                        if let image = listSubscription.lists.image, let imageUrl = URL(string: image) {
                            KFImage.url(imageUrl)
                                .resizable()
                                .roundCorner(radius: .widthFraction(0.2), roundingCorners: .all)
                                .loadDiskFileSynchronously()
                                .cacheMemoryOnly()
                                .frame(width: 28, height: 28)
                        }
                        Text(listSubscription.lists.title ?? "")
                    }
                case .inbox(let inboxSubscription):
                    HStack {
                        if let image = inboxSubscription.inboxes.image, let imageUrl = URL(string: image) {
                            KFImage.url(imageUrl)
                                .resizable()
                                .roundCorner(radius: .widthFraction(0.2), roundingCorners: .all)
                                .loadDiskFileSynchronously()
                                .cacheMemoryOnly()
                                .frame(width: 28, height: 28)
                        }
                        Text(inboxSubscription.title ?? "")
                    }
                }
            }
        }
        .onAppear {
            let baseURL = URL(string: "https://api.follow.is")!
            let service = SubscriptionService(baseURL: baseURL)

            Task {
                do {
                    let result = try await service.getSubscriptions().data
                    self.subscriptions = result
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}

#Preview {
    SubscriptionListView()
}
