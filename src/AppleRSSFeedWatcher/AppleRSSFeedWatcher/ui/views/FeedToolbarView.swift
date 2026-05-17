//
//  FeedToolbarView.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 17.05.26.
//

import SwiftUI

struct FeedToolbarView: View {
  @ObservedObject var viewModel: FeedViewModel

  var body: some View {
    HStack(alignment: .center, spacing: 16) {
      Picker("Select Filter", selection: $viewModel.itemFilter) {
        ForEach(ItemFilter.allCases, id: \.self) {
          Text($0.description)
        }
      }
      .pickerStyle(.segmented)
      .labelsHidden()

      Button {
        print("Search")
      } label: {
        Image(systemName: "magnifyingglass")
          .imageScale(.medium)
          .labelStyle(.iconOnly)
      }
      .buttonStyle(.borderless)
      .foregroundColor(Color(.labelColor))

      Spacer()

      OptionMenuButtonView()
    }
    .padding()
  }
}

#Preview {
  FeedToolbarView(viewModel: FeedViewModel(feedParser: FeedParser(feedUrl: URL(string: rssLink)!)))
}
