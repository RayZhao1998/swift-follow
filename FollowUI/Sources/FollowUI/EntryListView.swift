//
//  EntryListView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/15.
//

import FollowAPI
import SwiftUI
import Kingfisher

public struct EntryListView: View {
    @State private var entries: [PostEntries.EntryData] = []
    
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    NavigationLink(destination: EntryDetailView(entryId: entry.entries.id)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(entry.feeds.title ?? "")·\(DateFormatting.shared.formatTime(dateString: entry.entries.publishedAt))")
                                    .font(.system(size: 10, weight: .bold))
                                    .lineSpacing(2)
                                    .foregroundStyle(Color(red: 115/255, green: 115/255, blue: 115/255))
                                Text(entry.entries.title ?? "")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color(red: 163/255, green: 163/255, blue: 163/255))
                                    .lineLimit(1)
                                Text(entry.entries.description ?? "")
                                    .font(.system(size: 13))
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
            .navigationTitle("Articles")
        }
        .onAppear {
            let service = EntriesService()

            Task {
                do {
                    let result = try await service.postEntries()
                    self.entries = result.data ?? []
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}

#Preview {
    EntryListView()
}
