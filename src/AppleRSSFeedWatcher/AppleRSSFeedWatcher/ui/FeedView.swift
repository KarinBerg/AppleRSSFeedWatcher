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

        Spacer()

        OptionButtonView()
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
              .listRowSeparator(.hidden)
          }
        }
      }

      Divider()

      HStack {
        if let lastFetchDate = viewModel.lastFetchDate {
          Text("Content from: \(lastFetchDate.formatted(date: .abbreviated, time: .shortened))")
        } else {
          Text("Not yet updated")
        }
        if viewModel.isLoading {
          ProgressView()
            .controlSize(.small)
        }
        Spacer()
        Button {
          Task { @MainActor in
            await viewModel.loadFeed()
          }
        } label: {
          Image(systemName: "arrow.clockwise")
        }
        .buttonStyle(.borderless)
        .foregroundColor(Color(.labelColor))
        .disabled(viewModel.isLoading)
      }
      .font(.default)
      .foregroundColor(.secondary)
      .padding()
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
