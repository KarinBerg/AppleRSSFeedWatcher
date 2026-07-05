//
//  FeedListView.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 17.05.26.
//

import SwiftUI

struct FeedListView: View {
	let items: [FeedItem]

	var body: some View {
		if items.isEmpty {
			Text("No releases available")
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(Color(.textBackgroundColor))
		} else {
			List {
				ForEach(items) { item in
					FeedItemView(item: item)
						.listRowSeparator(.hidden)
				}
			}
		}
	}
}

#Preview {
	FeedListView(items: [])
}
