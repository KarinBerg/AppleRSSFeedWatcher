//
//  FeedItem.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 17.05.26.
//

import Foundation

struct FeedItem: Identifiable {
  public let id: String
  let title: String?
  let link: String?
  let description: String?
  let pubDate: Date?

  init(id: String, title: String, link: String?, description: String?, pubDate: Date?) {
    self.id = id
    self.title = title
    self.link = link
    self.description = description
    self.pubDate = pubDate
  }
}
