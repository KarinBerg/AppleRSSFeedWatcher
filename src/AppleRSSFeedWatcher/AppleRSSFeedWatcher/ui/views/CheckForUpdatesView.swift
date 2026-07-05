//
//  CheckForUpdatesView.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 05.07.26.
//

import SwiftUI

struct CheckForUpdatesView: View {
	@Environment(AppUpdater.self) private var updater

	var body: some View {
		Button("Check for Updates…", action: updater.checkForUpdates)
			.disabled(!updater.canCheckForUpdates)
	}
}
