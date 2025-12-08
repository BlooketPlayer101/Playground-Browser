import SwiftUI
import WebKit

struct ContentView: View {
    @EnvironmentObject var tabManager: TabManager
    
    // Local state for the TextField, kept in sync by modifiers
    @State private var urlInput: String = ""
    
    // Local state for the loading indicator, also kept in sync
    @State private var isTabLoading: Bool = false
    
    @State var showSettingsMenu = false
    @AppStorage("showTabListInSidebar") var showTabsInSidebar = false
    @AppStorage("homePage") var homePageUrl = "https://google.com"
    @AppStorage("useBeta") var showBetaFeatures = false
    @AppStorage("storedFavorites") var storedBrowsingHistory: Data = Data()
    
    @State var favorites: [String: String] = [:]
    
    var body: some View {
        ZStack {
            HStack {
                NavigationSplitView {
                    Form {
                        Text("Playground Browser Beta")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                        if showBetaFeatures {
                            Text("Warning: Alpha features are currently enabled. The browser may not function as expected.")
                                .foregroundStyle(.red)
                        }
                        
                        Button("Settings", systemImage: "gearshape") {
                            self.showSettingsMenu = true
                        }
                        
                        if showTabsInSidebar {
                            Section("Tabs") {
                                ForEach(Array(tabManager.tabs.keys.sorted {
                                    tabManager.tabs[$0]?.pageTitle ?? "" < tabManager.tabs[$1]?.pageTitle ?? ""
                                }), id: \.self) { tabId in
                                    Button {
                                        tabManager.activeTabId = tabId
                                    } label: {
                                        HStack {
                                            Text(tabManager.tabs[tabId]?.pageTitle ?? "New Tab")
                                            Spacer()
                                            if tabManager.activeTabId == tabId {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.accentColor)
                                            }
                                        }
                                    }
                                }
                                
                                Button("New Tab") {
                                    tabManager.addTab(urlString: homePageUrl)
                                }
                                .buttonStyle(.bordered)
                                
                                if tabManager.activeTabId != nil && tabManager.tabs.count > 1 {
                                    Button("Close Current Tab") {
                                        if let activeId = tabManager.activeTabId {
                                            tabManager.removeTab(id: activeId)
                                        }
                                    }
                                    .tint(.red)
                                }
                            }
                        }
                        
                        Section("Featured Sites") {
                            Button("Google") {
                                tabManager.activeTab?.loadURL(urlString: "https://www.google.com/?client=safari&channel=ipad_bm")
                            }
                            Button("Gordon County Schools") {
                                tabManager.activeTab?.loadURL(urlString: "https://www.gcbe.org")
                            }
                            Button("Schoology") {
                                tabManager.activeTab?.loadURL(urlString: "https://gcbe.schoology.com")
                            }
                            Button("Clever") {
                                tabManager.activeTab?.loadURL(urlString: "https://clever.com/in/gcbe/student/portal")
                            }
                            Button("Duolingo") {
                                tabManager.activeTab?.loadURL(urlString: "https://duolingo.com")
                            }
                            Button("Blooket") {
                                tabManager.activeTab?.loadURL(urlString: "https://blooket.com/")
                            }
                            Button("Gimkit") {
                                tabManager.activeTab?.loadURL(urlString: "https://gimkit.com")
                            }
                        }
                        
                        if showBetaFeatures {
                            Section("Favorites") {
                                Button("Placeholder") {
                                    tabManager.activeTab?.loadURL(urlString: "https://chatgpt,com")
                                }
                            }
                        }
                        
                        Section("Shortcuts and Tools") {
                            ShareLink("Share Current Page", item: tabManager.activeTab?.currentURL ?? "https://google.com")
                            Button("Open Current Site in Default Browser", systemImage: "safari") {
                                guard let urlString = tabManager.activeTab?.currentURL,
                                      let url = URL(string: urlString) else { return }
                                UIApplication.shared.open(url)
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                    .navigationTitle("Menu")
                    .background(RadialGradient(gradient: Gradient(colors: [.green.opacity(0.1), .white]), center: .top, startRadius: 5, endRadius: 400))
                } detail: {
                    VStack {
                        if let activeTab = tabManager.activeTab {
                            TabWebViewRepresentable(tabWebView: activeTab)
                                .id(activeTab.id)
                                .overlay(
                                    // This Group now uses the local @State variable for its visibility,
                                    // ensuring it updates reliably.
                                    Group {
                                        if isTabLoading {
                                            ProgressView()
                                                .progressViewStyle(.circular)
                                                .scaleEffect(2)
                                                .background(Color.black.opacity(0.4))
                                                .cornerRadius(10)
                                        }
                                    }
                                )
                        } else {
                            ContentUnavailableView("No Tab Selected", systemImage: "globe.central.south.asia.fill", description: Text("Please select an existing tab or create a new one to start browsing."))
                            Button("Add New Tab") {
                                tabManager.addTab(urlString: String(homePageUrl))
                            }
                            .padding()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    HStack {
                        Button(action: {
                            tabManager.activeTab?.goBack()
                        }){
                            Image(systemName: "arrow.backward")
                                .font(.title2)
                                .padding(.horizontal, 8)
                        }
                        .disabled(tabManager.activeTab?.webView.canGoBack == false)
                        
                        Button(action: {
                            tabManager.activeTab?.loadURL(urlString: homePageUrl)
                        }){
                            Image(systemName: "house")
                                .font(.title2)
                                .padding(.horizontal, 8)
                        }
                        
                        Button(action: {
                            tabManager.activeTab?.goForward()
                        }){
                            Image(systemName: "arrow.forward")
                                .font(.title2)
                                .padding(.horizontal, 8)
                        }
                        .disabled(tabManager.activeTab?.webView.canGoForward == false)
                        
                        TextField("Enter URL", text: $urlInput, onCommit: {
                            tabManager.activeTab?.loadURL(urlString: urlInput)
                        })
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        Button("Go") {
                            tabManager.activeTab?.loadURL(urlString: urlInput)
                        }
                        .padding(.horizontal, 8)
                        
                        Menu {
                            ForEach(Array(tabManager.tabs.keys.sorted {
                                tabManager.tabs[$0]?.pageTitle ?? "" < tabManager.tabs[$1]?.pageTitle ?? ""
                            }), id: \.self) { tabId in
                                Button {
                                    tabManager.activeTabId = tabId
                                } label: {
                                    Label(tabManager.tabs[tabId]?.pageTitle ?? "New Tab", systemImage: tabManager.activeTabId == tabId ? "checkmark" : "")
                                }
                            }
                            Divider()
                            Button("New Tab", systemImage: "plus.circle") {
                                tabManager.addTab(urlString: String(homePageUrl))
                            }
                            if tabManager.activeTabId != nil && tabManager.tabs.count > 1 {
                                Button("Close Current Tab", systemImage: "trash") {
                                    if let activeId = tabManager.activeTabId {
                                        tabManager.removeTab(id: activeId)
                                    }
                                }
                            }
                        } label: {
                            Label("Tabs", systemImage: "rectangle.portrait.on.rectangle.portrait")
                                .font(.title2)
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(8)
                }
            }
            if self.showSettingsMenu {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            self.showSettingsMenu = false
                            if homePageUrl.isEmpty {
                                homePageUrl = "https://www.google.com/?client=safari&channel=ipad_bm"
                            }
                        }
                    }
                // Assuming RealSettingsView is defined elsewhere in your project
                RealSettingsView()
                    .transition(.scale.animation(.spring()))
            }
        }
        .onChange(of: tabManager.activeTabId) { _, _ in
            // When the active tab changes, update BOTH local state variables
            urlInput = tabManager.activeTab?.currentURL ?? ""
            isTabLoading = tabManager.activeTab?.isLoading ?? false
        }
        .onReceive(tabManager.activeTab?.objectWillChange ?? .init()) { _ in
            DispatchQueue.main.async {
                // When the active tab's model changes (e.g., during a redirect),
                // sync BOTH the URL and the loading state.
                
                // Sync URL
                if let newURL = tabManager.activeTab?.currentURL, newURL != self.urlInput {
                    self.urlInput = newURL
                }
                
                // Sync loading state
                let newLoadingState = tabManager.activeTab?.isLoading ?? false
                if self.isTabLoading != newLoadingState {
                    self.isTabLoading = newLoadingState
                }
            }
        }
    }
}

// Assuming you have a RealSettingsView defined, otherwise this Preview will need it
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabManager())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
