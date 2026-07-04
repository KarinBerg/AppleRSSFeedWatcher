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

  init(provider: FeedProvider) {
    _viewModel = StateObject(wrappedValue: FeedViewModel(provider: provider))
  }

  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      FeedToolbarView(viewModel: viewModel)

      Divider()

      FeedListView(items: viewModel.filteredItems)

      Divider()

      FeedStatusBarView(viewModel: viewModel)
    }
    .frame(minWidth: 350, minHeight: 450)
  }
}

#Preview {
  FeedView(provider: FeedProvider(feedParser: FeedParser(feedUrl: URL(string: rssLink)!)))
}
