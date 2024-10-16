//
//  EntryDetailView.swift
//  FollowUI
//
//  Created by ZiyuanZhao on 2024/10/16.
//

import SwiftUI
import FollowAPI
import MarkdownUI

struct EntryDetailView: View {
    var entryId: String
    
    @State private var entry: GetEntries.EntriesData?
    
    var parsedContent: String {
        guard let content = entry?.entries.content else {
            return ""
        }
        
        return (try? HTMLToMarkdownParser().parseHTML(content: content)) ?? ""
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Markdown(parsedContent)
                    .markdownTheme(.docC)
                    .padding()
            }
                .navigationTitle(entry?.entries.title ?? "")
        }
            .onAppear {
                let service = EntriesService()

                Task {
                    do {
                        let result = try await service.getEntry(id: entryId)
                        self.entry = result.data
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
    }
}

#Preview {
    EntryDetailView(entryId: "69312689103010816")
}
