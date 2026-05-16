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

  var body: some View {
    VStack(alignment: .center) {
      HStack(alignment: .center, spacing: 16) {
        Picker("Select Filter", selection: $viewModel.itemFilter) {
          ForEach(ItemFilter.allCases, id: \.self) {
            Text($0.description)
          }
        }
        .pickerStyle(.segmented)
        .labelsHidden()

        // SearchButton
        Button {
          print("Search")
        } label: {
          Image(systemName: "magnifyingglass")
            .imageScale(.medium)
            .labelStyle(.iconOnly)
        }
        .buttonStyle(.borderless)
        .foregroundColor(Color(.labelColor))

        // PreferencesButton
        Button {
        } label: {
          Image(systemName: "gear")
        }
        .buttonStyle(.borderless)
        .foregroundColor(Color(.labelColor))

        Button(
          "Exit",
          action: {
            NSApp.terminate(nil)
          }
        )
      }
      .padding()

      Divider()

      if viewModel.feedItems.isEmpty {
        Text("No releases available")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Color(.textBackgroundColor))
      } else {
        List {
          ForEach(viewModel.feedItems) { item in
            FeedItemView(item: item)
          }
        }
      }

      Divider()
    }
    .frame(minWidth: 500, minHeight: 400)
  }

  init(feedParser: FeedParser) {
    let viewModel = FeedViewModel(feedParser: feedParser)
    _viewModel = StateObject(wrappedValue: viewModel)

    // Initial load of the RSS feed data at app start
    Task { @MainActor in
      await viewModel.loadFeed()
    }
  }

}

#Preview {
  FeedView(feedParser: FeedParser(feedUrl: URL(string: rssLink)!))
}
