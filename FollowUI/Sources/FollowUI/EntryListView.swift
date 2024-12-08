//
//  EntryListView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/15.
//

import FollowAPI
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
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            navigationStack
#if os(iOS)
                .toolbarVisibility(feeds == nil && lists == nil ? .visible : .hidden, for: .tabBar)
#endif
        } else {
            navigationStack
        }
    }
    
    private var navigationStack: some View {
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
                            EntryListItemView(entry: entry) {
                                EntryDetailView(entry: entry) {
                                    if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                                        entries[index].read = true
                                    }
                                }
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
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await refreshEntries()
                    }
                }
            }
            .navigationTitle(feeds?.title ?? lists?.title ?? "Reader")
        }
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

        isRefreshing = true
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
