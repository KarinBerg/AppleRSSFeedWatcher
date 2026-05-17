//
//  OptionMenuButtonView.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 16.05.26.
//

import SwiftUI

struct OptionMenuButtonView: View {
  var body: some View {
    Menu {
      Button("About...") {
        NSApp.activate(ignoringOtherApps: true)

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

        NSApp.orderFrontStandardAboutPanel(options: [
          .credits: credits
        ])
      }

      SettingsLink {
        Text("Settings...")
      }
      .keyboardShortcut(",", modifiers: .command)
      .simultaneousGesture(
        TapGesture().onEnded {
          NSApp.activate(ignoringOtherApps: true)
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
}

#Preview {
  OptionMenuButtonView()
}
