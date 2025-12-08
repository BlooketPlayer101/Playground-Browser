import Foundation
import SwiftUI

class TabManager: ObservableObject {
    @Published var tabs: [UUID: TabWebView] = [:]
    @Published var activeTabId: UUID?
    
    @AppStorage("homePage") var homePageUrl = "https://google.com"
    
    init() {
        // Ensure there's at least one tab when the app starts
        if tabs.isEmpty {
            addTab(urlString: homePageUrl, userAgent: UserAgents.defaultAgent)
        }
    }
    
    // Method to add a new tab, now with an optional userAgent parameter
    func addTab(urlString: String = "https://www.google.com", userAgent: String? = nil) {
        let tabId = UUID() // Generate a unique ID for the new tab
        // Create a new TabWebView, passing the ID, initial URL, and the user agent
        let newTab = TabWebView(id: tabId, initialURL: urlString, userAgent: userAgent)
        tabs[tabId] = newTab
        activeTabId = tabId // Make the new tab active immediately
    }
    
    // Method to remove a tab by its ID
    func removeTab(id: UUID) {
        tabs[id] = nil // Remove the tab from the dictionary
        
        // If the removed tab was the active one, find a new active tab
        if activeTabId == id {
            // Try to set the first available tab as active
            activeTabId = tabs.keys.first
            // If no tabs remain, activeTabId will become nil
        }
    }
    
    // Computed property to easily access the currently active TabWebView
    var activeTab: TabWebView? {
        if let id = activeTabId {
            return tabs[id]
        }
        return nil
    }
}
