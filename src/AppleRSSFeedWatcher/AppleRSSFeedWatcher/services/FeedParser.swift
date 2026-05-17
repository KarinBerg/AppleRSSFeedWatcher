//
//  AppleReleaseFeedParser.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 14.05.26.
//

import FeedKit
import Foundation

class FeedParser {
  private let feedUrl: URL

  init(feedUrl: URL) {
    self.feedUrl = feedUrl
  }

  func load() async throws -> [FeedItem] {
    var items: [FeedItem] = []
    let feed = try await RSSFeed(urlString: self.feedUrl.absoluteString)
    feed.channel?.items?.forEach { item in
      items.append(FeedItem.fromRssFeedItem(item: item))
    }
    return items
  }

}

extension FeedItem {

  static func fromRssFeedItem(item: RSSFeedItem) -> Self {
    Self(
      id: item.guid.debugDescription,
      title: item.title ?? "",
      link: item.link,
      description: item.description,
      pubDate: item.pubDate
    )
  }
}
