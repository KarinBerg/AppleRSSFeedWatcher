import AppKit
import Combine
import Sparkle
import UserNotifications

enum UpdateCheckInterval: CaseIterable {
	case daily
	case weekly
	case off

	init(automaticChecks: Bool, interval: TimeInterval) {
		if !automaticChecks {
			self = .off
		} else if interval >= UpdateCheckInterval.weekly.timeInterval {
			self = .weekly
		} else {
			self = .daily
		}
	}

	var timeInterval: TimeInterval {
		switch self {
		case .daily, .off: 24 * 60 * 60
		case .weekly: 7 * 24 * 60 * 60
		}
	}
}

@Observable
final class AppUpdater: NSObject, SPUStandardUserDriverDelegate {
	static let updateNotificationIdentifier = "app-update"

	@ObservationIgnored private var updaterController: SPUStandardUpdaterController!
	var canCheckForUpdates = false

	var updateCheckInterval: UpdateCheckInterval = .daily {
		didSet {
			let updater = updaterController.updater
			updater.automaticallyChecksForUpdates = updateCheckInterval != .off
			if updateCheckInterval != .off {
				updater.updateCheckInterval = updateCheckInterval.timeInterval
			}
		}
	}

	@ObservationIgnored private var cancellable: AnyCancellable?

	override init() {
		super.init()
		updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: self)
		let updater = updaterController.updater
		updateCheckInterval = UpdateCheckInterval(
			automaticChecks: updater.automaticallyChecksForUpdates,
			interval: updater.updateCheckInterval
		)
		cancellable = updater
			.publisher(for: \.canCheckForUpdates)
			.sink { [weak self] in self?.canCheckForUpdates = $0 }
	}

	func checkForUpdates() {
		NSApp.activate(ignoringOtherApps: true)
		updaterController.checkForUpdates(nil)
	}

	// MARK: - Gentle update reminders
	// As a menu bar app, Sparkle's update alert may appear behind other windows,
	// so scheduled updates found in the background are announced via a notification.
	// See https://sparkle-project.org/documentation/gentle-reminders/

	var supportsGentleScheduledUpdateReminders: Bool { true }

	func standardUserDriverShouldHandleShowingScheduledUpdate(
		_ update: SUAppcastItem,
		andInImmediateFocus immediateFocus: Bool
	) -> Bool {
		immediateFocus
	}

	func standardUserDriverWillHandleShowingUpdate(
		_ handleShowingUpdate: Bool,
		forUpdate update: SUAppcastItem,
		state: SPUUserUpdateState
	) {
		guard !handleShowingUpdate, !state.userInitiated else { return }

		let content = UNMutableNotificationContent()
		content.title = "Update available"
		content.body = "Version \(update.displayVersionString) of Apple RSS Feed Watcher is available."
		content.sound = UNNotificationSound.default

		let request = UNNotificationRequest(
			identifier: Self.updateNotificationIdentifier,
			content: content,
			trigger: nil
		)
		UNUserNotificationCenter.current().add(request)
	}

	func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
		removeUpdateNotification()
	}

	func standardUserDriverWillFinishUpdateSession() {
		removeUpdateNotification()
	}

	private func removeUpdateNotification() {
		UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [Self.updateNotificationIdentifier])
	}
}
