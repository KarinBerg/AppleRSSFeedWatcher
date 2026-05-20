//
//  FeedProvider.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 19.05.26.
//

import Combine
import Foundation

final class FeedProvider: ObservableObject {
  @Published private(set) var feedItems: [FeedItem] = []
  @Published private(set) var isLoading = false
  @Published private(set) var errorMessage: String?
  @Published private(set) var lastFetchDate: Date?

  private let feedParser: FeedParser
  private var refreshTask: Task<Void, Never>?
  private var cancellables = Set<AnyCancellable>()
  private var currentInterval: TimeInterval

  init(feedParser: FeedParser) {
    self.feedParser = feedParser
    self.currentInterval = Self.refreshIntervalFromDefaults()

    NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.handleDefaultsChange()
      }
      .store(in: &cancellables)

    startRefreshLoop()
  }

  deinit {
    refreshTask?.cancel()
  }

  func refresh() async {
    await loadFeed()
  }

  private func handleDefaultsChange() {
    let newInterval = Self.refreshIntervalFromDefaults()
    guard newInterval != currentInterval else { return }
    currentInterval = newInterval
    startRefreshLoop()
  }

  private func startRefreshLoop() {
    let interval = currentInterval
    refreshTask?.cancel()
    refreshTask = Task { @MainActor [weak self] in
      while !Task.isCancelled {
        await self?.loadFeed()
        do {
          try await Task.sleep(for: .seconds(interval))
        } catch {
          return
        }
      }
    }
  }

  @MainActor
  private func loadFeed() async {
    isLoading = true
    defer { isLoading = false }

    do {
      feedItems = try await feedParser.load()
      lastFetchDate = Date()
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private static func refreshIntervalFromDefaults() -> TimeInterval {
    let stored = UserDefaults.standard.double(forKey: SettingsKey.refreshInterval)
    #if DEBUG
    return stored > 0 ? stored : rssRefreshInterval
    #else
    return stored > 60 ? stored : rssRefreshInterval
    #endif
  }
}
