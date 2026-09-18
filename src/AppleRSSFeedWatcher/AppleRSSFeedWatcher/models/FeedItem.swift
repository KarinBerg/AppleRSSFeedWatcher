//
//  FeedItem.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 17.05.26.
//

import Foundation

struct FeedItem: Identifiable, Codable {
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

	// The classification flags are derived from the title, so only the raw values are persisted.
	private enum CodingKeys: String, CodingKey {
		case id, title, link, description, pubDate
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.init(
			id: try container.decode(String.self, forKey: .id),
			title: try container.decodeIfPresent(String.self, forKey: .title) ?? "",
			link: try container.decodeIfPresent(String.self, forKey: .link),
			description: try container.decodeIfPresent(String.self, forKey: .description),
			pubDate: try container.decodeIfPresent(Date.self, forKey: .pubDate)
		)
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
