//
//  AppleRSSFeedWatcherApp.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 14.05.26.
//

import SwiftUI

@main
struct MainApp: App {
  var body: some Scene {
    MenuBarExtra(
      "Apple RSS Feed",
      systemImage: "wifi.square"
    ) {
      let parser = FeedParser(feedUrl: URL(string: "https://developer.apple.com/news/releases/rss/releases.rss")!)
      FeedView(feedParser: parser)
    }
    .menuBarExtraStyle(.window)
  }
}
