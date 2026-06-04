//
//  FeedProvider.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 19.05.26.
//

import Combine
import Foundation
import UserNotifications

final class FeedProvider: ObservableObject {
  @Published private(set) var feedItems: [FeedItem] = []
  @Published private(set) var isLoading = false
  @Published private(set) var errorMessage: String?
  @Published private(set) var lastFetchDate: Date?

  private let feedParser: FeedParser
  private var refreshTask: Task<Void, Never>?
  private var cancellables = Set<AnyCancellable>()
  private var currentInterval: TimeInterval
  private let notificationCenter = UNUserNotificationCenter.current()

  init(feedParser: FeedParser) {
    self.feedParser = feedParser
    self.currentInterval = Self.refreshIntervalFromDefaults()

    Task { @MainActor in
      do {
        try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
      } catch {
        // Ignore for now
      }
    }

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
    errorMessage = nil
    isLoading = true
    defer { isLoading = false }

    do {
      let newFeedItems = try await feedParser.load()

      if lastFetchDate != nil {
        let existingIds = Set(feedItems.map(\.id))
        let addedItems = newFeedItems.filter { !existingIds.contains($0.id) }

        if !addedItems.isEmpty {
          if await areNotificationsAuthorized() {
            await sendNotification(addedItems: addedItems)
          }
        }
      }

      feedItems = newFeedItems
      lastFetchDate = Date()
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  private func areNotificationsAuthorized() async -> Bool {
    await notificationCenter.notificationSettings().authorizationStatus == .authorized
  }

  private func sendNotification(addedItems: [FeedItem]) async {
    let content = UNMutableNotificationContent()
    content.title = "New Apple releases"
    content.body =
      addedItems.count == 1
      ? "Apple has released a new update. Check it out!"
      : "Apple has released \(addedItems.count) new updates. Check them out!"
    content.sound = UNNotificationSound.default
    content.userInfo = ["link": "https://developer.apple.com/news/releases/"]

    let request = UNNotificationRequest(identifier: "new-items-\(addedItems.map(\.id).sorted().joined(separator: "-"))", content: content, trigger: nil)
    do {
      try await notificationCenter.add(request)
    } catch {
      // Ignore for now
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
