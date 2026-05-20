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

  private let provider: FeedProvider
  private var cancellable: AnyCancellable?

  init(provider: FeedProvider) {
    self.provider = provider
    self.cancellable = provider.objectWillChange.sink { [weak self] _ in
      self?.objectWillChange.send()
    }
  }

  var filteredItems: [FeedItem] {
    switch itemFilter {
    case .all:
      return provider.feedItems
    case .beta:
      return provider.feedItems.filter { $0.isBeta || $0.isReleaseCandidate }
    case .release:
      return provider.feedItems.filter { $0.isRelease }
    }
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
