import AppKit
import SwiftUI

@main
struct BlogAdminApp: App {
  init() {
    NSApplication.shared.setActivationPolicy(.regular)
    NSApplication.shared.activate(ignoringOtherApps: true)
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
