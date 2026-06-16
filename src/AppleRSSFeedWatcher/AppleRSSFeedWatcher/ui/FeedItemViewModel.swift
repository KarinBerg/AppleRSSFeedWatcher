//
//  FeedItemViewModel.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 14.05.26.
//

import Combine
import Foundation

class FeedItemViewModel: ObservableObject {
  @Published var item: FeedItem

  private static let newEntryAgeThreshold: TimeInterval = 6 * 60 * 60

  private static let fullDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .short
    return formatter
  }()

  private static let relativeDateFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter
  }()

  init(item: FeedItem) {
    self.item = item
  }

  var title: String {
    item.title ?? "Untitled"
  }

  var description: String {
    item.description ?? "No description"
  }

  var link: URL? {
    guard let link = item.link else {
      return nil
    }
    return URL(string: link)
  }

  var relativeDate: String {
    guard let pubDate = item.pubDate else {
      return "Unknown date"
    }
    return relativeTime(from: pubDate)
  }

  var date: String {
    guard let pubDate = item.pubDate else {
      return "Unknown date"
    }

    return Self.fullDateFormatter.string(from: pubDate)
  }

  var isNew: Bool {
    isNew(referenceDate: Date())
  }

  func isNew(referenceDate: Date) -> Bool {
    guard let pubDate = item.pubDate else {
      return false
    }

    let age = referenceDate.timeIntervalSince(pubDate)
    return age >= 0 && age < Self.newEntryAgeThreshold
  }

  private func relativeTime(from date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()

    if now.timeIntervalSince(date) < 60 {
      return "Just now"
    }

    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
    return Self.relativeDateFormatter
      .localizedString(
        from: DateComponents(
          year: -components.year!,
          month: -components.month!,
          day: -components.day!,
          hour: -components.hour!,
          minute: -components.minute!
        )
      )
  }

}
