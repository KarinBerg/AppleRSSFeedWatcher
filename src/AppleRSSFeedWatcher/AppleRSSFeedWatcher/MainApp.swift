//
//  AppleRSSFeedWatcherApp.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 14.05.26.
//

import SwiftUI

let rssLink: String = "https://developer.apple.com/news/releases/rss/releases.rss"
let rssRefreshInterval: TimeInterval = 60 * 60

@main
struct MainApp: App {
  private let parser = FeedParser(feedUrl: URL(string: rssLink)!)

  var body: some Scene {
    MenuBarExtra(
      "Apple RSS Feed",
      systemImage: "wifi.square"
    ) {
      FeedView(feedParser: parser)
    }
    .menuBarExtraStyle(.window)
  }
}
