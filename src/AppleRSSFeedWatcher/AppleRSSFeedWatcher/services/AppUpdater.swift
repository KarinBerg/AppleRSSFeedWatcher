import Combine
import Sparkle

@Observable
final class AppUpdater {
	private let updaterController: SPUStandardUpdaterController
	var canCheckForUpdates = false

	private var cancellable: AnyCancellable?

	init() {
		updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
		cancellable = updaterController.updater
			.publisher(for: \.canCheckForUpdates)
			.sink { [weak self] in self?.canCheckForUpdates = $0 }
	}

	func checkForUpdates() {
		updaterController.checkForUpdates(nil)
	}
}
