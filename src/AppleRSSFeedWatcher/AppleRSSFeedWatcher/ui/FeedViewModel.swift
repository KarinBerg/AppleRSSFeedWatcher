//
//  FeedViewModel.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 14.05.26.
//

import Combine
import Foundation

final class FeedViewModel: ObservableObject {
	@Published var itemFilter: ItemFilter = .all
	@Published var searchText: String = ""

	private let provider: FeedProvider
	private var cancellable: AnyCancellable?

	init(provider: FeedProvider) {
		self.provider = provider
		self.cancellable = provider.objectWillChange.sink { [weak self] _ in
			self?.objectWillChange.send()
		}
	}

	var filteredItems: [FeedItem] {
		let filtered: [FeedItem]
		switch itemFilter {
		case .all:
			filtered = provider.feedItems
		case .beta:
			filtered = provider.feedItems.filter { $0.isBeta || $0.isReleaseCandidate }
		case .release:
			filtered = provider.feedItems.filter { $0.isRelease }
		}

		let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !query.isEmpty else { return filtered }

		return filtered.filter { $0.title?.localizedCaseInsensitiveContains(query) ?? false }
	}

	var isLoading: Bool { provider.isLoading }
	var errorMessage: String? { provider.errorMessage }
	var lastFetchDate: Date? { provider.lastFetchDate }

	func loadFeed() async {
		await provider.refresh()
	}
}

enum ItemFilter: CaseIterable, CustomStringConvertible {
	case all, beta, release

	public var description: String {
		switch self {
		case .all:
			return "All"
		case .release:
			return "Released"
		case .beta:
			return "Beta"
		}
	}
}
