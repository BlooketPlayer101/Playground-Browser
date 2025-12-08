import SwiftUI
import WebKit

// Define your custom user agent strings for easy access and management
enum UserAgents {
    // Example: Mimics Safari on an iPad Pro running iOS 17
    static let iPadProSafari = "Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
    
    // Example: Mimics Chrome on a macOS desktop
    static let desktopChrome = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    
    // Example: A custom user agent for your application
    static let customAppAgent = "PlaygroundBrowser/1.0 (iOS; AppleWebKit/605.1.15)"
    
    // Default to use if no specific user agent is provided
    static let defaultAgent = iPadProSafari
}

// ObservableObject to manage a single tab's WKWebView and its state
// Conforms to Identifiable to provide a unique ID for SwiftUI's .id() modifier
class TabWebView: NSObject, ObservableObject, WKNavigationDelegate, Identifiable {
    let id: UUID // Unique identifier for this tab
    @Published var webView: WKWebView
    @Published var varUserAgent: String? // Store the user agent used for this tab
    @Published var currentURL: String = "about:blank"
    @Published var isLoading: Bool = false
    @Published var pageTitle: String = "New Tab"
    
    // Initializer now accepts an optional userAgent string
    init(id: UUID = UUID(), initialURL: String = "https://www.google.com", userAgent: String? = nil) {
        self.id = id
        
        let config = WKWebViewConfiguration()
        // No user agent setting on config
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        super.init()
        self.webView.navigationDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        
        // --- CRITICAL MODIFICATION FOR USER AGENT ---
        // Set the customUserAgent on the WKWebView instance itself, after it's initialized.
        let effectiveUserAgent = userAgent ?? UserAgents.defaultAgent
        self.webView.customUserAgent = effectiveUserAgent // <-- Set here!
        self.varUserAgent = effectiveUserAgent // Store it so we know what was used
        
        if let url = URL(string: initialURL) {
            self.webView.load(URLRequest(url: url))
            self.currentURL = initialURL
        }
    }
    
    func loadURL(urlString: String) {
        // Basic URL sanitization: prepend "http://" if no scheme is present
        var finalUrlString = urlString
        if !urlString.contains("://") && !urlString.starts(with: "about:") {
            finalUrlString = "http://\(urlString)"
        }
        
        if let url = URL(string: finalUrlString) {
            self.webView.load(URLRequest(url: url))
            self.currentURL = url.absoluteString
        } else {
            print("Invalid URL: \(urlString)")
            // Optionally, load an error page or show an alert
            self.webView.loadHTMLString("<h1>Error: Couldn't load page. Either you have no internet or the URL is invalid.</h1>", baseURL: nil)
        }
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
        // Update currentURL as soon as navigation starts
        currentURL = webView.url?.absoluteString ?? "about:blank"
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        // Update currentURL and pageTitle when page finishes loading
        currentURL = webView.url?.absoluteString ?? "about:blank"
        pageTitle = webView.title ?? "Untitled"
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        print("Failed to load (provisional): \(error.localizedDescription)")
        // Handle specific errors if needed
        self.webView.loadHTMLString("<h1>Error: Couldn't load page. Either you have no internet or the URL is invalid.</h1>", baseURL: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        print("Navigation failed: \(error.localizedDescription)")
        // Handle specific errors if needed
    }
}

// UIViewRepresentable for embedding WKWebView from TabWebView
struct TabWebViewRepresentable: UIViewRepresentable {
    @ObservedObject var tabWebView: TabWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return tabWebView.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No direct updates needed here. SwiftUI will recreate the entire
        // TabWebViewRepresentable due to the .id() modifier in ContentView
        // when a different TabWebView instance is passed.
    }
}
import SwiftUI
import WebKit

// Define your custom user agent strings for easy access and management
enum UserAgents {
    // Example: Mimics Safari on an iPad Pro running iOS 17
    static let iPadProSafari = "Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
    
    // Example: Mimics Chrome on a macOS desktop
    static let desktopChrome = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    
    // Example: A custom user agent for your application
    static let customAppAgent = "PlaygroundBrowser/1.0 (iOS; AppleWebKit/605.1.15)"
    
    // Default to use if no specific user agent is provided
    static let defaultAgent = iPadProSafari
}

// ObservableObject to manage a single tab's WKWebView and its state
// Conforms to Identifiable to provide a unique ID for SwiftUI's .id() modifier
class TabWebView: NSObject, ObservableObject, WKNavigationDelegate, Identifiable {
    let id: UUID // Unique identifier for this tab
    @Published var webView: WKWebView
    @Published var varUserAgent: String? // Store the user agent used for this tab
    @Published var currentURL: String = "about:blank"
    @Published var isLoading: Bool = false
    @Published var pageTitle: String = "New Tab"
    
    // Initializer now accepts an optional userAgent string
    init(id: UUID = UUID(), initialURL: String = "https://www.google.com", userAgent: String? = nil) {
        self.id = id
        
        let config = WKWebViewConfiguration()
        // No user agent setting on config
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        super.init()
        self.webView.navigationDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        
        // --- CRITICAL MODIFICATION FOR USER AGENT ---
        // Set the customUserAgent on the WKWebView instance itself, after it's initialized.
        let effectiveUserAgent = userAgent ?? UserAgents.defaultAgent
        self.webView.customUserAgent = effectiveUserAgent // <-- Set here!
        self.varUserAgent = effectiveUserAgent // Store it so we know what was used
        
        if let url = URL(string: initialURL) {
            self.webView.load(URLRequest(url: url))
            self.currentURL = initialURL
        }
    }
    
    func loadURL(urlString: String) {
        // Basic URL sanitization: prepend "http://" if no scheme is present
        var finalUrlString = urlString
        if !urlString.contains("://") && !urlString.starts(with: "about:") {
            finalUrlString = "http://\(urlString)"
        }
        
        if let url = URL(string: finalUrlString) {
            self.webView.load(URLRequest(url: url))
            self.currentURL = url.absoluteString
        } else {
            print("Invalid URL: \(urlString)")
            // Optionally, load an error page or show an alert
            self.webView.loadHTMLString("<h1>Error: Couldn't load page. Either you have no internet or the URL is invalid.</h1>", baseURL: nil)
        }
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
        // Update currentURL as soon as navigation starts
        currentURL = webView.url?.absoluteString ?? "about:blank"
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        // Update currentURL and pageTitle when page finishes loading
        currentURL = webView.url?.absoluteString ?? "about:blank"
        pageTitle = webView.title ?? "Untitled"
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        print("Failed to load (provisional): \(error.localizedDescription)")
        // Handle specific errors if needed
        self.webView.loadHTMLString("<h1>Error: Couldn't load page. Either you have no internet or the URL is invalid.</h1>", baseURL: nil)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        print("Navigation failed: \(error.localizedDescription)")
        // Handle specific errors if needed
    }
}

// UIViewRepresentable for embedding WKWebView from TabWebView
struct TabWebViewRepresentable: UIViewRepresentable {
    @ObservedObject var tabWebView: TabWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return tabWebView.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No direct updates needed here. SwiftUI will recreate the entire
        // TabWebViewRepresentable due to the .id() modifier in ContentView
        // when a different TabWebView instance is passed.
    }
}
