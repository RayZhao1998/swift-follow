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

    @State private var isLoading: Bool = false
    @State private var isLoadingMore: Bool = false
    @State private var isRefreshing: Bool = false
    @State private var isEnd: Bool = false

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
                                            .foregroundStyle(Color(red: 115 / 255, green: 115 / 255, blue: 115 / 255))
                                        Text(entry.entries.title ?? "")
                                            .font(.custom("SNProVF-Medium", size: 14))
                                            .foregroundStyle(Color(red: 163 / 255, green: 163 / 255, blue: 163 / 255))
                                            .lineLimit(1)
                                        Text(entry.entries.description ?? "")
                                            .font(.custom("SNProVF", size: 13))
                                            .foregroundStyle(Color(red: 115 / 255, green: 115 / 255, blue: 115 / 255))
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
                        if !isEnd {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .onAppear {
                                Task {
                                    await loadMoreEntries()
                                }
                            }
                        }
                    }
                    .refreshable {
                        await refreshEntries()
                    }
                }
            }
            .navigationTitle(feeds?.title ?? lists?.title ?? "Reader")
        }
        .toolbarVisibility(feeds == nil && lists == nil ? .visible : .hidden, for: .tabBar)
        .font(.custom("SNProVF-Regular", size: 16))
        .onAppear {
            Task {
                await loadEntries()
            }
        }
    }
    
    private func loadEntries() async {
        guard !isLoading else { return }
        
        isLoading = true
        let service = EntriesService()
        
        do {
            let result = try await service.postEntries(feedId: feeds?.id, listId: lists?.id)
            entries = result.data ?? []
            isEnd = result.remaining == 0
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
    
    private func refreshEntries() async {
        guard !isRefreshing else { return }
        
        self.isRefreshing = true
        let service = EntriesService()
        
        do {
            let result = try await service.postEntries(feedId: feeds?.id, listId: lists?.id)
            entries = result.data ?? []
            isEnd = result.remaining == 0
            withAnimation {
                isRefreshing = false
            }
        } catch {
            withAnimation {
                isRefreshing = false
            }
            print("Error: \(error)")
        }
    }
    
    private func loadMoreEntries() async {
        guard !isLoadingMore, !isLoading, !isEnd, !entries.isEmpty else { return }
        
        isLoadingMore = true
        let service = EntriesService()
        
        do {
            let result = try await service.postEntries(
                feedId: feeds?.id,
                listId: lists?.id,
                publishedAfter: entries.last?.entries.publishedAt
            )
            entries.append(contentsOf: result.data ?? [])
            isEnd = result.remaining == 0
            withAnimation {
                isLoadingMore = false
            }
        } catch {
            withAnimation {
                isLoadingMore = false
            }
            print("Error: \(error)")
        }
    }
}

#Preview {
    EntryListView()
}
