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

  var body: some View {
    Form {
      Picker("Refresh feed every:", selection: $refreshInterval) {
        Text("15 minutes").tag(TimeInterval(15 * 60))
        Text("30 minutes").tag(TimeInterval(30 * 60))
        Text("1 hour").tag(TimeInterval(60 * 60))
        Text("2 hours").tag(TimeInterval(2 * 60 * 60))
        Text("6 hours").tag(TimeInterval(6 * 60 * 60))
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
}

#Preview {
  SettingsView()
}
