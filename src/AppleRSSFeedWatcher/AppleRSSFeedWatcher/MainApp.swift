//
//  AppleRSSFeedWatcherApp.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 14.05.26.
//

import SwiftUI

let rssLink: String = "https://developer.apple.com/news/releases/rss/releases.rss"
let rssRefreshInterval: TimeInterval = 60 * 60

@main
struct MainApp: App {
	@State private var updater: AppUpdater

	private let feedProvider: FeedProvider

	init() {
		let updater = AppUpdater()
		_updater = State(initialValue: updater)
		feedProvider = FeedProvider(
			feedParser: FeedParser(feedUrl: URL(string: rssLink)!),
			appUpdater: updater
		)
	}

	var body: some Scene {
		MenuBarExtra(
			"Apple RSS Feed",
			image: "StatusBarIcon"
		) {
			FeedView(provider: feedProvider).environment(updater)
		}
		.menuBarExtraStyle(.window)

		Settings {
			SettingsView().environment(updater)
		}
	}
}
