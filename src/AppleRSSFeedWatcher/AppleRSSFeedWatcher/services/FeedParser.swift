//
//  AppleReleaseFeedParser.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 14.05.26.
//

import FeedKit
import Foundation

struct FeedItem: Identifiable {
  public let id: String
  let title: String?
  let link: String?
  let description: String?
  let pubDate: Date?

  init(item: RSSFeedItem) {
    self.id = item.guid.debugDescription
    self.title = item.title
    self.link = item.link
    self.description = item.description
    self.pubDate = item.pubDate
  }

  init(id: String, title: String, link: String?, description: String?, pubDate: Date?) {
    self.id = id
    self.title = title
    self.link = link
    self.description = description
    self.pubDate = pubDate
  }
}

class FeedParser {
  private let feedUrl: URL

  init(feedUrl: URL) {
    self.feedUrl = feedUrl
  }

  func load() async throws -> [FeedItem] {
    var items: [FeedItem] = []
    let feed = try await RSSFeed(urlString: self.feedUrl.absoluteString)
    feed.channel?.items?.forEach { item in
      items.append(FeedItem(item: item))

    }
    return items
  }

}
