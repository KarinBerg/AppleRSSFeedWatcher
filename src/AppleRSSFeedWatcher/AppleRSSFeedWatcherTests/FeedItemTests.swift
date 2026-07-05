//
//  FeedItemTests.swift
//  AppleRSSFeedWatcherTests
//

import Foundation
import Testing
@testable import AppleRSSFeedWatcher

@Suite("Feed item tests") struct FeedItemTests {

	@MainActor
	func isNewWhenPublishedLessThan6HoursAgo() {
		let referenceDate = Date()
		let item = FeedItem(
			id: "new",
			title: "New entry",
			link: nil,
			description: nil,
			pubDate: referenceDate.addingTimeInterval(-5 * 60 * 60)
		)

		#expect(FeedItemViewModel(item: item).isNew(referenceDate: referenceDate))
	}

	@MainActor
	func isNotNewWhenPublished6HoursAgoOrEarlier() {
		let referenceDate = Date()
		let item = FeedItem(
			id: "old",
			title: "Old entry",
			link: nil,
			description: nil,
			pubDate: referenceDate.addingTimeInterval(-6 * 60 * 60)
		)

		#expect(!FeedItemViewModel(item: item).isNew(referenceDate: referenceDate))
	}

	@MainActor
	func isNotNewWithoutPublicationDate() {
		let referenceDate = Date()
		let item = FeedItem(
			id: "unknown",
			title: "Unknown date entry",
			link: nil,
			description: nil,
			pubDate: nil
		)

		#expect(!FeedItemViewModel(item: item).isNew(referenceDate: referenceDate))
	}

}
