import SwiftUI

@main
struct BrowserApp: App {
    // Create a single instance of TabManager and make it an EnvironmentObject
    @StateObject var tabManager = TabManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabManager) // Inject TabManager into the environment
        }
    }
}
