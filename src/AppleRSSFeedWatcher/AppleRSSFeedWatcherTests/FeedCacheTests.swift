//
//  FeedCacheTests.swift
//  AppleRSSFeedWatcherTests
//

import Foundation
import Testing
@testable import AppleRSSFeedWatcher

@Suite("Feed cache tests") struct FeedCacheTests {

	@Test
	@MainActor
	func savedItemsAreLoadedBack() throws {
		let cache = FeedCache(fileUrl: Self.temporaryFileUrl())
		let fetchDate = Date(timeIntervalSince1970: 1_700_000_000)
		let pubDate = Date(timeIntervalSince1970: 1_699_000_000)
		let items = [
			FeedItem(
				id: "beta",
				title: "macOS 26.1 beta 2",
				link: "https://example.com/beta",
				description: "A beta release",
				pubDate: pubDate
			),
			FeedItem(
				id: "release",
				title: "Xcode 26.1",
				link: nil,
				description: nil,
				pubDate: nil
			)
		]

		cache.save(items: items, fetchDate: fetchDate)
		let cached = try #require(cache.load())

		#expect(cached.fetchDate == fetchDate)
		#expect(cached.items.map(\.id) == ["beta", "release"])
		#expect(cached.items[0].title == "macOS 26.1 beta 2")
		#expect(cached.items[0].link == "https://example.com/beta")
		#expect(cached.items[0].description == "A beta release")
		#expect(cached.items[0].pubDate == pubDate)
		#expect(cached.items[1].link == nil)
		#expect(cached.items[1].pubDate == nil)
	}

	@Test
	@MainActor
	func classificationFlagsAreDerivedOnLoad() throws {
		let cache = FeedCache(fileUrl: Self.temporaryFileUrl())
		let items = [
			FeedItem(id: "beta", title: "macOS 26.1 beta 2", link: nil, description: nil, pubDate: nil),
			FeedItem(id: "release", title: "Xcode 26.1", link: nil, description: nil, pubDate: nil)
		]

		cache.save(items: items, fetchDate: Date())
		let cached = try #require(cache.load())

		#expect(cached.items[0].isBeta)
		#expect(!cached.items[0].isRelease)
		#expect(cached.items[1].isRelease)
		#expect(!cached.items[1].isBeta)
	}

	@Test
	@MainActor
	func derivedFlagsAreNotPersisted() throws {
		let fileUrl = Self.temporaryFileUrl()
		let cache = FeedCache(fileUrl: fileUrl)
		let item = FeedItem(id: "beta", title: "macOS 26.1 beta 2", link: nil, description: nil, pubDate: nil)

		cache.save(items: [item], fetchDate: Date())
		let json = try #require(String(data: try Data(contentsOf: fileUrl), encoding: .utf8))

		#expect(!json.contains("isBeta"))
		#expect(!json.contains("isReleaseCandidate"))
		#expect(!json.contains("isRelease"))
	}

	@Test
	@MainActor
	func loadReturnsNilWhenFileIsMissing() {
		let cache = FeedCache(fileUrl: Self.temporaryFileUrl())

		#expect(cache.load() == nil)
	}

	@Test
	@MainActor
	func loadReturnsNilForUnreadableContent() throws {
		let fileUrl = Self.temporaryFileUrl()
		try FileManager.default.createDirectory(
			at: fileUrl.deletingLastPathComponent(),
			withIntermediateDirectories: true
		)
		try Data("not json".utf8).write(to: fileUrl)

		#expect(FeedCache(fileUrl: fileUrl).load() == nil)
	}

	private static func temporaryFileUrl() -> URL {
		URL.temporaryDirectory
			.appending(path: "FeedCacheTests-\(UUID().uuidString)")
			.appending(path: "feed-cache.json")
	}
}
