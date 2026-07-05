//
//  OptionMenuButton.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 16.05.26.
//

import SwiftUI

struct OptionMenuButton: View {
	var body: some View {
		Menu {
			Button("About...") {
				NSApp.activate(ignoringOtherApps: true)
				let credits = getAboutPanelCredits()
				NSApp.orderFrontStandardAboutPanel(options: [
					.credits: credits
				])
			}

			CheckForUpdatesView()

			SettingsLink {
				Text("Settings...")
			}
			.keyboardShortcut(",", modifiers: .command)
			.simultaneousGesture(
				TapGesture().onEnded {
					DispatchQueue.main.async {
						NSApp.activate(ignoringOtherApps: true)
						bringSettingsWindowToFront()
					}
				}
			)

			Divider()

			Button("Quit") {
				NSApp.terminate(nil)
			}
			.keyboardShortcut("q", modifiers: .command)
		} label: {
			Image(systemName: "ellipsis.circle")
				.imageScale(.medium)
		}
		.menuStyle(.borderlessButton)
		.menuIndicator(.hidden)
		.foregroundColor(Color(.labelColor))
		.fixedSize()
	}

	/// Brings the SwiftUI Settings window to the front.
	///
	/// `SettingsLink` creates its window a moment after the tap is handled, so we
	/// retry briefly until the window exists and then order it front regardless of
	/// the app's activation state.
	private func bringSettingsWindowToFront(attempt: Int = 0) {
		let identifier = "com_apple_SwiftUI_Settings_window"
		if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == identifier }) {
			window.makeKeyAndOrderFront(nil)
			window.orderFrontRegardless()
		} else if attempt < 10 {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
				bringSettingsWindowToFront(attempt: attempt + 1)
			}
		}
	}

	private func getAboutPanelCredits() -> NSAttributedString {
		let credits = NSMutableAttributedString(
			string: "This app watches the official ",
			attributes: [.foregroundColor: NSColor.labelColor]
		)

		credits.append(
			NSAttributedString(
				string: "Apple Developer releases RSS feed",
				attributes: [
					.link: URL(string: "https://developer.apple.com/news/releases/")!,
					.foregroundColor: NSColor.linkColor,
				]
			)
		)

		credits.append(
			NSAttributedString(
				string: " and notifies you of new releases. Collected content is not modified in any way and copyrights belongs to Apple Inc.\n\n",
				attributes: [.foregroundColor: NSColor.labelColor]
			)
		)

		credits.append(
			NSAttributedString(string: "Copyright © 2026 Karin Berg. All rights reserved.\n\n", attributes: [.foregroundColor: NSColor.labelColor])
		)

		credits.append(
			NSAttributedString(string: "Report issues to ", attributes: [.foregroundColor: NSColor.labelColor])
		)

		credits.append(
			NSAttributedString(
				string: "github.com",
				attributes: [
					.link: URL(string: "https://github.com/KarinBerg/AppleRSSFeedWatcher/issues")!,
					.foregroundColor: NSColor.linkColor,
				]
			)
		)

		return credits
	}

}

#Preview {
	OptionMenuButton()
}
