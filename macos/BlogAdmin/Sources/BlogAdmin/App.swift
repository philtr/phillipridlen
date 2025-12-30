import AppKit
import SwiftUI

@main
struct BlogAdminApp: App {
  @AppStorage("BlogAdminCanSave") private var canSave = false

  init() {
    NSApplication.shared.setActivationPolicy(.regular)
    NSApplication.shared.activate(ignoringOtherApps: true)
    let icon =
      Bundle.module.url(forResource: "BlogAdmin", withExtension: "png")
        .flatMap { NSImage(contentsOf: $0) } ??
      Bundle.module.url(forResource: "BlogAdmin", withExtension: "icns")
        .flatMap { NSImage(contentsOf: $0) }

    if let icon {
      NSApplication.shared.applicationIconImage = dockIcon(from: icon)
    }
  }

  private func dockIcon(from image: NSImage) -> NSImage {
    let size = NSSize(width: 1024, height: 1024)
    let canvas = NSImage(size: size)
    let inset: CGFloat = 90
    let rect = NSRect(x: inset, y: inset, width: size.width - inset * 2, height: size.height - inset * 2)

    canvas.lockFocus()
    image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
    canvas.unlockFocus()

    return canvas
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .commands {
      CommandGroup(before: .saveItem) {
        Button("Save") {
          savePost()
        }
        .keyboardShortcut("s", modifiers: [.command])
        .disabled(!canSave)
      }
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

  private func savePost() {
    NotificationCenter.default.post(name: .init("BlogAdminSavePost"), object: nil)
  }
}
