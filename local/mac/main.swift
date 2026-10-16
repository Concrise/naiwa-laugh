// 奶蛙大笑 Mac 版：一个窗口里放 WKWebView，加载 .app 里的 index.html（帧和笑声都内嵌在里面）
import Cocoa
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ note: Notification) {
        let conf = WKWebViewConfiguration()
        conf.mediaTypesRequiringUserActionForPlayback = []
        let web = WKWebView(frame: NSRect(x: 0, y: 0, width: 480, height: 860), configuration: conf)
        let page = Bundle.main.url(forResource: "index", withExtension: "html")!
        web.loadFileURL(page, allowingReadAccessTo: page.deletingLastPathComponent())

        window = NSWindow(contentRect: web.frame, styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "奶蛙大笑"
        window.appearance = NSAppearance(named: .aqua)   // 页面是白底，标题栏也固定用浅色
        window.backgroundColor = .white
        window.minSize = NSSize(width: 360, height: 640)
        window.contentView = web
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool { true }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)

// 没有 nib，手动加个菜单，⌘Q 才能退出
let menu = NSMenu(), item = NSMenuItem()
menu.addItem(item)
item.submenu = NSMenu()
item.submenu!.addItem(withTitle: "退出奶蛙大笑", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
app.mainMenu = menu
app.run()
