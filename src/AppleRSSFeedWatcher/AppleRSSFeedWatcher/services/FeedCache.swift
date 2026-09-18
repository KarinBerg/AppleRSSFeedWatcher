//
//  FeedCache.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 18.09.26.
//

import Foundation

struct CachedFeed: Codable {
	let items: [FeedItem]
	let fetchDate: Date
}

struct FeedCache {
	private let fileUrl: URL

	init(fileUrl: URL = URL.applicationSupportDirectory.appending(path: "feed-cache.json")) {
		self.fileUrl = fileUrl
	}

	func load() -> CachedFeed? {
		guard let data = try? Data(contentsOf: fileUrl) else { return nil }
		return try? JSONDecoder().decode(CachedFeed.self, from: data)
	}

	func save(items: [FeedItem], fetchDate: Date) {
		guard let data = try? JSONEncoder().encode(CachedFeed(items: items, fetchDate: fetchDate))
		else { return }

		try? FileManager.default.createDirectory(
			at: fileUrl.deletingLastPathComponent(),
			withIntermediateDirectories: true
		)
		try? data.write(to: fileUrl, options: .atomic)
	}
}
