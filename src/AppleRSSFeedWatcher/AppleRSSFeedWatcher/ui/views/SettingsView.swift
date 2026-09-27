//
//  SettingsView.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 17.05.26.
//

import ServiceManagement
import SwiftUI

struct SettingsView: View {
	@AppStorage(SettingsKey.refreshInterval) private var refreshInterval: TimeInterval = rssRefreshInterval
	@State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
	@Environment(AppUpdater.self) private var updater

	var body: some View {
		@Bindable var updater = updater

		Form {
			Picker("Refresh feed every:", selection: $refreshInterval) {
				#if DEBUG
				Text("1 minute").tag(TimeInterval(60))
				#endif
				Text("15 minutes").tag(TimeInterval(15 * 60))
				Text("30 minutes").tag(TimeInterval(30 * 60))
				Text("1 hour").tag(TimeInterval(60 * 60))
				Text("2 hours").tag(TimeInterval(2 * 60 * 60))
				Text("6 hours").tag(TimeInterval(6 * 60 * 60))
			}

			Picker("Check for updates:", selection: $updater.updateCheckInterval) {
				Text("Daily").tag(UpdateCheckInterval.daily)
				Text("Weekly").tag(UpdateCheckInterval.weekly)
				Text("Off").tag(UpdateCheckInterval.off)
			}

			Toggle(
				"Launch at Login",
				isOn: Binding(
					get: { launchAtLogin },
					set: { newValue in
						do {
							if newValue {
								try SMAppService.mainApp.register()
							} else {
								try SMAppService.mainApp.unregister()
							}
							launchAtLogin = newValue
						} catch {
							print("Failed to update launch at login: \(error)")
							launchAtLogin = SMAppService.mainApp.status == .enabled
						}
					}
				)
			)
		}
		.formStyle(.grouped)
		.frame(width: 400)
		.fixedSize()
	}
}

enum SettingsKey {
	static let refreshInterval = "rssRefreshInterval"
	static let notifiedItemIds = "notifiedItemIds"
}

#Preview {
	SettingsView().environment(AppUpdater())
}
