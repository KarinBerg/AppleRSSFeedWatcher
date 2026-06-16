//
//  FeedItemView.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 14.05.26.
//

import Combine
import SwiftUI

struct FeedItemView: View {
  @StateObject private var viewModel: FeedItemViewModel

  var body: some View {
    HStack {
      if let link = viewModel.link {
        Link(viewModel.title, destination: link)
          .font(.system(size: 12, weight: titleFontWeight, design: .default))
          .lineLimit(nil)
      } else {
        Text(viewModel.title)
          .font(.system(size: 12, weight: titleFontWeight, design: .default))
          .lineLimit(nil)
      }

      Spacer()

      Text(viewModel.relativeDate)
        .font(.system(size: 10, weight: .light, design: .default))
        .foregroundColor(.secondary)
        .lineLimit(1)
        .help(viewModel.date)

    }
    .padding([.vertical], 4)
  }

  init(item: FeedItem) {
    _viewModel = StateObject(wrappedValue: FeedItemViewModel(item: item))
  }

  private var titleFontWeight: Font.Weight {
	  viewModel.isNew ? .bold : .regular
  }
}

#Preview {
  let item = FeedItem(id: "2", title: "title", link: "", description: "", pubDate: Date.now)
  FeedItemView(item: item)
}
