//
//  EntryListItemView.swift
//  FollowUI
//
//  Created by Luke on 11/27/24.
//

import FollowAPI
import Kingfisher
import SwiftUI

private struct EntryListItemText: View {
    let topSubtitle: String
    let headline: String
    let content: String
    let read: Bool
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(topSubtitle)
                .font(.custom("SNProVF-Bold", size: 11))
                .foregroundStyle(Color.secondaryLabel)
                .lineSpacing(2)
                .lineLimit(1)
            Text(headline)
                .font(.custom("SNProVF-Medium", size: 16))
                .foregroundStyle(read ? Color.secondaryLabel : Color.label)
                .lineLimit(1)
            Text(content)
                .font(.custom("SNProVF", size: 15))
                .foregroundStyle(Color.secondaryLabel)
                .lineSpacing(2)
                .lineLimit(3)
        }
    }
}

public struct EntryListItemView<Destination>: View where Destination : View {
    let entry: PostEntries.EntryData
    let destination: () -> Destination
    
    public var body: some View {
        NavigationLink(destination: destination) {
            ZStack {
                HStack(alignment: .top) {
                    HStack(alignment: .center) {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundStyle(entry.read == false ? Color(red: 255 / 255, green: 92 / 255, blue: 0 / 255) : .clear)
                        if let image = entry.feeds.imageUrl,
                           let imageUrl = URL(string: image)
                        {
                            KFImage.url(imageUrl)
                                .resizable()
                                .roundCorner(
                                    radius: .widthFraction(0.2),
                                    roundingCorners: .all
                                )
                                .loadDiskFileSynchronously()
                                .cacheMemoryOnly()
                                .frame(width: 20, height: 20)
                        }
                    }
                    ZStack(alignment: .topLeading) {
                        EntryListItemText(
                            topSubtitle: "\(entry.feeds.title ?? "")·\(DateFormatting.shared.formatTime(dateString: entry.entries.publishedAt))",
                            headline: entry.entries.title ?? "",
                            content: entry.entries.description ?? "",
                            read: entry.read == true
                        )
                        EntryListItemText(
                            topSubtitle: "",
                            headline: "",
                            content: "\n\n",
                            read: entry.read == true
                        )
                    }
                    Spacer()
                    if let image = entry.entries.media?.first?.url.replaceImgUrlIfNeed(), let imageUrl = URL(string: image) {
                        KFImage.url(imageUrl)
                            .resizable()
                            .serialize(as: .PNG)
                            .loadDiskFileSynchronously()
                            .cacheMemoryOnly()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 20))
    }
}
