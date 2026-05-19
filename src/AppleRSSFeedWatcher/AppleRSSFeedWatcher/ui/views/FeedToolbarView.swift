//
//  FeedToolbarView.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 17.05.26.
//

import SwiftUI

struct FeedToolbarView: View {
  @ObservedObject var viewModel: FeedViewModel
  @State var itemFilter: ItemFilter = .all

  var body: some View {
    HStack(alignment: .center, spacing: 16) {
      Picker("Select Filter", selection: $itemFilter) {
        ForEach(ItemFilter.allCases, id: \.self) { filter in
          Text(filter.description).tag(filter)
        }
      }
      .pickerStyle(.segmented)
      .labelsHidden()
      .onChange(of: itemFilter) { _, filter in
        viewModel.itemFilter = filter
      }

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

      OptionMenuButton()
    }
    .padding()
  }
}

#Preview {
  FeedToolbarView(viewModel: FeedViewModel(feedParser: FeedParser(feedUrl: URL(string: rssLink)!)))
}
