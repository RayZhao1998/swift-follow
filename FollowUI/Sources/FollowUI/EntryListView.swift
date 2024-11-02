//
//  EntryListView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/15.
//

import FollowAPI
import Kingfisher
import SwiftUI

public struct EntryListView: View {
    var feeds: Subscriptions.Feed?
    var lists: Subscriptions.List?

    @State private var entries: [PostEntries.EntryData] = []

    @State private var isLoading: Bool = true

    public init() {}

    public init(feeds: Subscriptions.Feed) {
        self.feeds = feeds
    }

    public init(lists: Subscriptions.List) {
        self.lists = lists
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(entries) { entry in
                            NavigationLink(destination: EntryDetailView(entryId: entry.entries.id)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(entry.feeds.title ?? "")·\(DateFormatting.shared.formatTime(dateString: entry.entries.publishedAt))")
                                            .font(.custom("SNProVF-Bold", size: 10))
                                            .lineSpacing(2)
                                            .foregroundStyle(Color(red: 115/255, green: 115/255, blue: 115/255))
                                        Text(entry.entries.title ?? "")
                                            .font(.custom("SNProVF-Medium", size: 14))
                                            .foregroundStyle(Color(red: 163/255, green: 163/255, blue: 163/255))
                                            .lineLimit(1)
                                        Text(entry.entries.description ?? "")
                                            .font(.custom("SNProVF", size: 13))
                                            .foregroundStyle(Color(red: 115/255, green: 115/255, blue: 115/255))
                                            .lineSpacing(2)
                                            .lineLimit(3)
                                    }
                                    Spacer()
                                    if let image = entry.entries.media?.first?.url.replaceImgUrlIfNeed(), let imageUrl = URL(string: image) {
                                        KFImage.url(imageUrl)
                                            .resizable()
                                            .serialize(as: .PNG)
                                            .loadDiskFileSynchronously()
                                            .cacheMemoryOnly()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .navigationTitle(feeds?.title ?? lists?.title ?? "Reader")
        }
        .toolbarVisibility(feeds == nil && lists == nil ? .visible : .hidden, for: .tabBar)
        .font(.custom("SNProVF-Regular", size: 16))
        .onAppear {
            let service = EntriesService()

            Task {
                do {
                    let result = try await service.postEntries(feedId: feeds?.id, listId: lists?.id)
                    self.entries = result.data ?? []
                    withAnimation {
                        isLoading = false
                    }
                } catch {
                    withAnimation {
                        isLoading = false
                    }
                    print("Error: \(error)")
                }
            }
        }
    }
}

#Preview {
    EntryListView()
}
