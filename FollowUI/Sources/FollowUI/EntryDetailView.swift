//
//  EntryDetailView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/16.
//

import FollowAPI
import MarkdownUI
import SwiftUI

struct EntryDetailView: View {
    var entry: PostEntries.EntryData
    var onRead: () -> Void

    @Environment(\.openURL) var openURL
    @State private var entryDetail: GetEntries.EntriesData?

    var parsedContent: String {
        guard let content = entryDetail?.entries.content else {
            return ""
        }

        return (try? HTMLToMarkdownParser().parseHTML(content: content)) ?? ""
    }

    var body: some View {
        ScrollView {
            Markdown(parsedContent)
                .markdownTheme(.docC)
                .padding()
        }
        .navigationTitle(entry.entries.title ?? "")
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar(content: {
            if let urlString = entry.entries.url, let url = URL(string: urlString) {
                Button("Open in Safari", systemImage: "safari") {
                    openURL(url)
                }
            }
        })
        .onAppear {
            let service = EntriesService()

            Task {
                do {
                    let result = try await service.getEntry(id: entry.entries.id)
                    self.entryDetail = result.data

                    if !(entry.read ?? false) {
                        let readsService = ReadsService()
                        let _ = try await readsService.postReads(entryIds: [entry.id])
                        onRead()
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}
