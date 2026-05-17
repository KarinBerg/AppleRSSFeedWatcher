//
//  MenuView.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 14.05.26.
//

import SwiftUI
import os.log

struct FeedView: View {
  @StateObject private var viewModel: FeedViewModel
  @AppStorage(SettingsKey.refreshInterval) private var refreshInterval: TimeInterval = rssRefreshInterval

  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      FeedToolbarView(viewModel: viewModel)

      Divider()

      FeedListView(items: viewModel.feedItems)

      Divider()

      FeedStatusBarView(viewModel: viewModel)
    }
    .frame(minWidth: 300, minHeight: 400)
    .onChange(of: refreshInterval) { _, newValue in
      viewModel.startAutoRefresh(interval: newValue)
    }
  }

  init(feedParser: FeedParser) {
    let viewModel = FeedViewModel(feedParser: feedParser)
    _viewModel = StateObject(wrappedValue: viewModel)

    let storedInterval = UserDefaults.standard.double(forKey: SettingsKey.refreshInterval)
    let interval = storedInterval > 0 ? storedInterval : rssRefreshInterval
    viewModel.startAutoRefresh(interval: interval)
  }

}

#Preview {
  FeedView(feedParser: FeedParser(feedUrl: URL(string: rssLink)!))
}
