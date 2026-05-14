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

  private let feedParser: FeedParser

  init(feedParser: FeedParser) {
    self.feedParser = feedParser
  }

  func loadFeed() async {
    isLoading = true

    defer {
      isLoading = false
    }

    do {
      feedItems = try await feedParser.load()
    } catch {
      errorMessage = error.localizedDescription
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
