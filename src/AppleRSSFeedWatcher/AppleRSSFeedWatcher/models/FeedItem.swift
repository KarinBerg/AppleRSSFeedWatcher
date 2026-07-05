//
//  FeedItem.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 17.05.26.
//

import Foundation

struct FeedItem: Identifiable {
	public let id: String
	let title: String?
	let link: String?
	let description: String?
	let pubDate: Date?

	public let isBeta: Bool
	public let isReleaseCandidate: Bool
	public let isRelease: Bool

	init(id: String, title: String, link: String?, description: String?, pubDate: Date?) {
		self.id = id
		self.title = title
		self.link = link
		self.description = description
		self.pubDate = pubDate

		self.isBeta = Self.isBeta(title: title)
		self.isReleaseCandidate = Self.isReleaseCandidate(title: title)
		self.isRelease = !isBeta && !isReleaseCandidate
	}
}

private extension FeedItem {

	static func isBeta(title: String) -> Bool {
		let keywords = [" beta", "beta "]
		return keywords.contains(where: title.lowercased().contains)
	}

	static func isReleaseCandidate(title: String) -> Bool {
		let keywords = ["release candidate", " rc", "rc "]
		return keywords.contains(where: title.lowercased().contains)
	}
}
