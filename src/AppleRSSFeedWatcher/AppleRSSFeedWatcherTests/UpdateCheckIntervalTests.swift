//
//  UpdateCheckIntervalTests.swift
//  AppleRSSFeedWatcherTests
//

import Foundation
import Testing
@testable import AppleRSSFeedWatcher

@Suite("Update check interval tests") struct UpdateCheckIntervalTests {

	@MainActor
	@Test(arguments: [
		(false, TimeInterval(24 * 60 * 60), UpdateCheckInterval.off),
		(false, TimeInterval(7 * 24 * 60 * 60), UpdateCheckInterval.off),
		(true, TimeInterval(60 * 60), UpdateCheckInterval.daily),
		(true, TimeInterval(24 * 60 * 60), UpdateCheckInterval.daily),
		(true, TimeInterval(7 * 24 * 60 * 60), UpdateCheckInterval.weekly),
	])
	func mapsSparkleSettings(automaticChecks: Bool, interval: TimeInterval, expected: UpdateCheckInterval) {
		#expect(UpdateCheckInterval(automaticChecks: automaticChecks, interval: interval) == expected)
	}

	@MainActor
	@Test(arguments: [UpdateCheckInterval.daily, .weekly])
	func roundTripsTimeInterval(interval: UpdateCheckInterval) {
		#expect(UpdateCheckInterval(automaticChecks: true, interval: interval.timeInterval) == interval)
	}
}
