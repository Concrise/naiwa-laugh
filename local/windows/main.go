// 奶蛙大笑 Windows 版：用系统自带的 WebView2 开一个窗口加载内嵌的 index.html（帧和笑声都在里面）。
// 没装 WebView2 的老系统就在本机起一个只给自己用的小服务器，用默认浏览器打开。
package main

import (
	_ "embed"
	"net"
	"net/http"
	"os/exec"
	"runtime"

	webview "github.com/jchv/go-webview2"
)

//go:embed index.html
var page []byte

func main() {
	runtime.LockOSThread()
	w := webview.NewWithOptions(webview.WebViewOptions{
		AutoFocus: true,
		WindowOptions: webview.WindowOptions{
			Title:  "奶蛙大笑",
			Width:  480,
			Height: 860,
			IconId: 1, // main.syso 里的图标
			Center: true,
		},
	})
	if w == nil {
		openInBrowser()
		return
	}
	defer w.Destroy()
	w.SetSize(360, 640, webview.HintMin)
	// 先在本机起服务器再用 http 地址加载：直接 SetHtml 的页面没有来源，有的 WebView2 版本会拦掉 data: 音频
	w.Navigate(serve())
	w.Run()
}

func serve() string {
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		panic(err)
	}
	go http.Serve(ln, http.HandlerFunc(func(rw http.ResponseWriter, r *http.Request) {
		rw.Header().Set("Content-Type", "text/html; charset=utf-8")
		rw.Write(page)
	}))
	return "http://" + ln.Addr().String() + "/"
}

func openInBrowser() {
	url := serve()
	exec.Command("rundll32", "url.dll,FileProtocolHandler", url).Start()
	select {} // 浏览器开着页面期间保持服务器在跑
}
