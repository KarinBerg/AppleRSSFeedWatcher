//
//  OptionButton.swift
//  AppleRSSFeedWatcher
//
//  Created by Karin Berg on 16.05.26.
//

import SwiftUI

struct OptionButtonView: View {
  var body: some View {
    Menu {
      Button("About...") {
        print("About")
      }

      Button("Settings...") {
        print("Settings")
      }
      .keyboardShortcut(",", modifiers: .command)

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
  OptionButtonView()
}
