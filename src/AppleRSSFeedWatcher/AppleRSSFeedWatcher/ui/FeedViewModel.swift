//
//  FeedViewModel.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 14.05.26.
//

import Combine
import Foundation

class FeedViewModel: ObservableObject {
  @Published var feedItems: [FeedItem] = []
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var itemFilter: ItemFilter = .all
  @Published var lastFetchDate: Date?

  private let feedParser: FeedParser
  private var refreshTask: Task<Void, Never>?

  init(feedParser: FeedParser) {
    self.feedParser = feedParser
  }

  deinit {
    refreshTask?.cancel()
  }

  func loadFeed() async {
    isLoading = true

    defer {
      isLoading = false
    }

    do {
      feedItems = try await feedParser.load()
      lastFetchDate = Date()
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  func startAutoRefresh(interval: TimeInterval = rssRefreshInterval) {
    refreshTask?.cancel()
    refreshTask = Task { @MainActor [weak self] in
      while !Task.isCancelled {
        await self?.loadFeed()
        do {
          try await Task.sleep(for: .seconds(interval))
        } catch {
          return
        }
      }
    }
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
