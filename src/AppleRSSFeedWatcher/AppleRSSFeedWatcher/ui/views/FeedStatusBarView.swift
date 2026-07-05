//
//  FeedStatusBarView.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 17.05.26.
//

import SwiftUI

struct FeedStatusBarView: View {
	@ObservedObject var viewModel: FeedViewModel

	var body: some View {
		HStack {
			var fetchInfo: String {
				if let lastFetchDate = viewModel.lastFetchDate {
					return "Last updated: \(lastFetchDate.formatted(date: .abbreviated, time: .shortened))"
				} else {
					return "Not yet updated"
				}
			}
			Text(fetchInfo)

			if viewModel.isLoading {
				ProgressView()
					.controlSize(.small)
			}

			Spacer()

			Button {
				Task { @MainActor in
					await viewModel.loadFeed()
				}
			} label: {
				Image(systemName: "arrow.clockwise")
			}
			.buttonStyle(.borderless)
			.foregroundColor(Color(.labelColor))
			.disabled(viewModel.isLoading)
		}
		.foregroundColor(.secondary)
		.padding()
	}
}

#Preview {
	FeedStatusBarView(viewModel: FeedViewModel(provider: FeedProvider(feedParser: FeedParser(feedUrl: URL(string: rssLink)!))))
}
