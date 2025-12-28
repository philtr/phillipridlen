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
    .commands {
      CommandGroup(replacing: .newItem) {
        Button("New Post") {
          newPost()
        }
        .keyboardShortcut("n", modifiers: [.command])

        Button("New Window") {
          NSApp.sendAction(#selector(NSResponder.newWindowForTab(_:)), to: nil, from: nil)
        }
        .keyboardShortcut("N", modifiers: [.command, .shift])
      }
      CommandGroup(after: .newItem) {
        Button("Choose Folder…") {
          chooseFolder()
        }
        .keyboardShortcut("o", modifiers: [.command])
      }
    }
  }

  private func newPost() {
    NotificationCenter.default.post(name: .init("BlogAdminNewPost"), object: nil)
  }

  private func chooseFolder() {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false
    panel.title = "Choose Blog Repository"

    if panel.runModal() == .OK, let url = panel.url {
      UserDefaults.standard.set(url.path, forKey: "repoPath")
    }
  }
}
