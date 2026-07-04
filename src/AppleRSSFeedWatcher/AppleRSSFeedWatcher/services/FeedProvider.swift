//
//  FeedProvider.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 19.05.26.
//

import AppKit
import Combine
import Foundation
import UserNotifications

final class FeedProvider: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
  @Published private(set) var feedItems: [FeedItem] = []
  @Published private(set) var isLoading = false
  @Published private(set) var errorMessage: String?
  @Published private(set) var lastFetchDate: Date?

  private let feedParser: FeedParser
  private var refreshTask: Task<Void, Never>?
  private var cancellables = Set<AnyCancellable>()
  private var currentInterval: TimeInterval
  private let notificationCenter = UNUserNotificationCenter.current()

	private let fullDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .full
		formatter.timeStyle = .short
		return formatter
	}()

  init(feedParser: FeedParser) {
    self.feedParser = feedParser
    self.currentInterval = Self.refreshIntervalFromDefaults()

    super.init()

    notificationCenter.delegate = self

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

      if await areNotificationsAuthorized() {
        await checkForNewItemsAndSendNotifications(newFeedItems)
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

  private func checkForNewItemsAndSendNotifications(_ newFeedItems: [FeedItem]) async {
    let notifiedIds = Set(
      UserDefaults.standard.stringArray(forKey: SettingsKey.notifiedItemIds) ?? []
    )
    let addedItems = newFeedItems.filter { !notifiedIds.contains($0.id) }

    guard !addedItems.isEmpty else { return }

    for item in addedItems {
      await sendNotification(for: item)
    }

    // Persist all known IDs, capped to the current new feed size (+200) to avoid unbounded growth
    let updatedIds = Array(notifiedIds.union(newFeedItems.map(\.id)).suffix(newFeedItems.count + 200))
    UserDefaults.standard.set(updatedIds, forKey: SettingsKey.notifiedItemIds)
  }

  private func sendNotification(for item: FeedItem) async {
    let title = item.title ?? "Unkwown"
    var pubDateString = ""
    if let pubDate = item.pubDate {
      pubDateString = fullDateFormatter.string(from: pubDate)
    }
    let content = UNMutableNotificationContent()

    content.title = "New Apple release of '\(title)'"
    content.body = "Apple released a new version of '\(title)' at \(pubDateString)."
    if let description = item.description {
      content.subtitle = description
    }
    content.sound = UNNotificationSound.default
    if let link = item.link {
      content.userInfo = ["link": link]
    } else {
      content.userInfo = ["link": "https://developer.apple.com/news/releases/"]
    }

    let request = UNNotificationRequest(
      identifier: "new-item-\(item.id)",
      content: content,
      trigger: nil
    )
    do {
      try await notificationCenter.add(request)
    } catch {
      // Ignore for now
    }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
  ) async {
    guard let linkString = response.notification.request.content.userInfo["link"] as? String,
          let url = URL(string: linkString)
    else { return }

    NSWorkspace.shared.open(url)
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
