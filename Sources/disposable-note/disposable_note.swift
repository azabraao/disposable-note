import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMainMenu()

        let frame = NSRect(x: 0, y: 0, width: 300, height: 300)
        let window = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = ""
        window.center()

        let scrollView = NSScrollView(frame: frame)
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let textView = NSTextView(frame: frame)
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.usesFindBar = true
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.font = NSFont(name: "Noto Serif", size: NSFont.systemFontSize) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)

        scrollView.documentView = textView
        window.contentView = scrollView
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(textView)

        self.window = window
    }

    @MainActor
    private func setupMainMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        let appName = ProcessInfo.processInfo.processName
        let quitTitle = "Quit \(appName)"
        let quitItem = NSMenuItem(
            title: quitTitle,
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        quitItem.keyEquivalentModifierMask = [.command]
        appMenu.addItem(quitItem)

        appMenuItem.submenu = appMenu
        NSApp.mainMenu = mainMenu
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct DisposableNoteMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.activate(ignoringOtherApps: true)
        app.run()
    }
}
