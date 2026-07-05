//
//  FeedToolbarView.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 17.05.26.
//

import SwiftUI

struct FeedToolbarView: View {
	@ObservedObject var viewModel: FeedViewModel
	@State var itemFilter: ItemFilter = .all
	@State private var isSearching = false
	@FocusState private var isSearchFocused: Bool

	var body: some View {
		VStack(spacing: 0) {
			HStack(alignment: .center, spacing: 16) {
				Picker("Select Filter", selection: $itemFilter) {
					ForEach(ItemFilter.allCases, id: \.self) { filter in
						Text(filter.description).tag(filter)
					}
				}
				.pickerStyle(.segmented)
				.labelsHidden()
				.onChange(of: itemFilter) { _, filter in
					viewModel.itemFilter = filter
				}

				Button {
					toggleSearching()
				} label: {
					Image(systemName: "magnifyingglass")
						.imageScale(.medium)
						.labelStyle(.iconOnly)
				}
				.buttonStyle(.borderless)
				.foregroundColor(isSearching ? Color.accentColor : Color(.labelColor))

				Spacer()

				OptionMenuButton()
			}
			.padding()

			if isSearching {
				searchField
					.padding(.horizontal)
					.padding(.bottom)
					.transition(.move(edge: .top).combined(with: .opacity))
			}
		}
		.animation(.easeInOut(duration: 0.2), value: isSearching)
	}

	private var searchField: some View {
		HStack(spacing: 8) {
			Image(systemName: "magnifyingglass")
				.imageScale(.medium)
				.foregroundColor(Color(.secondaryLabelColor))

			TextField("Search title", text: $viewModel.searchText)
				.textFieldStyle(.plain)
				.focused($isSearchFocused)
				.onSubmit { isSearchFocused = false }

			Button {
				stopSearching()
			} label: {
				Image(systemName: "xmark.circle.fill")
					.imageScale(.medium)
					.labelStyle(.iconOnly)
			}
			.buttonStyle(.borderless)
			.foregroundColor(Color(.secondaryLabelColor))
		}
	}

	private func toggleSearching() {
		if isSearching {
			stopSearching()
		} else {
			startSearching()
		}
	}

	private func startSearching() {
		isSearchFocused = true
		isSearching = true
	}

	private func stopSearching() {
		viewModel.searchText = ""
		isSearchFocused = false
		isSearching = false
	}
}

#Preview {
	FeedToolbarView(viewModel: FeedViewModel(provider: FeedProvider(feedParser: FeedParser(feedUrl: URL(string: rssLink)!))))
}
